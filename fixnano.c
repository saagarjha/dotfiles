#define _GNU_SOURCE

#include <dlfcn.h>
#include <inttypes.h>
#include <limits.h>
#include <regex.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <wordexp.h>

#ifdef __APPLE__
#include <mach-o/dyld.h>
#endif

#ifdef __APPLE__
#define OVERRIDE_NAME(function) overridden_##function
#define ORIGINAL_NAME(function) function
#else
#define OVERRIDE_NAME(function) function
#define ORIGINAL_NAME(function) original_##function
#endif

#define VERSION_REGEX "[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?"

FILE *(*original_fopen)(const char *restrict, const char *restrict);
int (*original_fclose)(FILE *);
int (*original_fileno)(FILE *stream);

__attribute__((weak)) const char *getprogname();
__attribute__((weak)) extern char *program_invocation_short_name;

bool initialized = false;
bool should_inject = false;

wordexp_t expansion;
typedef uintmax_t nano_version[3];
nano_version current_version;
struct {
	char *buffer;
	size_t size;
} nanorc;
FILE *nanorc_file;

static void *find_libc_symbol(const char *name) {
	void *symbol = dlsym(RTLD_NEXT, name);
	if (symbol) {
		return symbol;
	} else {
		// If dlsym failed with "RTLD_NEXT used in code not dynamically loaded"
		Dl_info info;
		dladdr(fmemopen /* Something inside of libc */, &info);
		return dlsym(dlopen(info.dli_fname, RTLD_LAZY | RTLD_NOLOAD), name);
	}
}

static void parse_version(char *version_string, nano_version version) {
	char *version_end;
	for (size_t i = 0; i < sizeof(nano_version) / sizeof(*version); ++i) {
		version[i] = strtoumax(version_string, &version_end, 10);
		version[i] *= version_end != version_string;
		if (version_end == version_string) {
			break;
		} else if (*(version_string = version_end) != '.') {
			break;
		}
		++version_string;
	}
}

static void get_current_nano_version() {
	char executable[PATH_MAX];
#ifdef __APPLE__
	uint32_t executable_size = sizeof(executable);
	_NSGetExecutablePath(executable, &executable_size);
#else
	executable[readlink("/proc/self/exe", executable, sizeof(executable))] = '\0';
#endif
	char command[1024];
	FILE *output = popen(snprintf(command, sizeof(command),
		"DYLD_INSERT_LIBRARIES= LD_PRELOAD= %s --version |"
		" grep -E -o '(version |v)" VERSION_REGEX "' |"
		" grep -E -o '" VERSION_REGEX "'",
		executable) > 0 ? command : "echo version 0", "r");
	char *line = NULL;
	size_t size;
	getline(&line, &size, output)
		;
	pclose(output);
	parse_version(strlen(line) ? line : "0", current_version);
	free(line);
}

static void fixnano_init() {
	should_inject = (getprogname && !strcmp(getprogname(), "nano")) ||
	                (&program_invocation_short_name && !strcmp(program_invocation_short_name, "nano"));
	original_fopen = find_libc_symbol("fopen");
	original_fclose = find_libc_symbol("fclose");
	original_fileno = find_libc_symbol("fileno");
	if (should_inject) {
		wordexp("~/.nanorc", &expansion, 0);
		get_current_nano_version();
	}
	initialized = true;
}

__attribute__((destructor)) static void fixnano_fini() {
	wordfree(&expansion);
	free(nanorc.buffer);
}

// I can't figure out how to make fixnano_init be called before any other
// library's constructor, so just force initialization on first call to the
// functions we interpose. (If we don't do this, certain applications will call
// these functions in their constructors and the "original" functions will never
// be set.)
#define ENSURE_INITIALIZATION() \
	if (!initialized) {         \
		fixnano_init();         \
	}

static void add_nanorc_line(char *line) {
	size_t length = strlen(line);
	nanorc.buffer = realloc(nanorc.buffer, nanorc.size + length);
	memcpy(nanorc.buffer + nanorc.size, line, length);
	nanorc.size += length;
}

static char *extract_regex_match(char *line, regmatch_t *match) {
	size_t length = match->rm_eo - match->rm_so;
	char *result = malloc(length + 1);
	memcpy(result, line + match->rm_so, length);
	result[length] = '\0';
	return result;
}

static int verscmp(nano_version v1, nano_version v2) {
	for (size_t i = 0; i < sizeof(nano_version) / sizeof(*v1); ++i) {
		if (v2[i] < v1[i]) {
			return 1;
		} else if (v1[i] < v2[i]) {
			return -1;
		}
	}
	return 0;
}

static inline bool supported_version(char *line, regmatch_t *matches) {
	nano_version minimum_version = {0, 0, 0};
	nano_version maximum_version = {-1, -1, -1};
	if (0 <= matches[1].rm_so) {
		parse_version(line + matches[1].rm_so, minimum_version);
	}
	if (0 <= matches[4].rm_so) {
		parse_version(line + matches[4].rm_so, maximum_version);
	}
	return verscmp(current_version, minimum_version) >= 0 && verscmp(current_version, maximum_version) <= 0;
}

FILE *OVERRIDE_NAME(fopen)(const char *restrict path, const char *restrict mode) {
	ENSURE_INITIALIZATION();
	if (should_inject && !strcmp(path, *expansion.we_wordv)) {
		FILE *file = ORIGINAL_NAME(fopen)(path, mode);
		regex_t regex;
		regcomp(&regex, "^# (" VERSION_REGEX ")?-(" VERSION_REGEX ")? (.*)", REG_EXTENDED);
		regmatch_t matches[8];
		char *line = NULL;
		size_t size = 0;
		while (0 < getline(&line, &size, file)) {
			if (!regexec(&regex, line, sizeof(matches) / sizeof(*matches), matches, 0) &&
			    supported_version(line, matches)) {
				char *setting = extract_regex_match(line, matches + 7);
				add_nanorc_line(setting);
				free(setting);
			} else {
				add_nanorc_line(line);
			}
		}
		regfree(&regex);
		free(line);
		return nanorc_file = fmemopen(nanorc.buffer, nanorc.size, mode);
	} else {
		return ORIGINAL_NAME(fopen)(path, mode);
	}
}

int OVERRIDE_NAME(fclose)(FILE *stream) {
	ENSURE_INITIALIZATION();
	if (stream == nanorc_file) {
		nanorc_file = NULL;
	}
	return ORIGINAL_NAME(fclose)(stream);
}

int OVERRIDE_NAME(fileno)(FILE *stream) {
	ENSURE_INITIALIZATION();
	// Nano's getline reimplementation used to check that this returns something
	// other than -1. Return -2 to bypass the check for our memory buffer.
	return stream == nanorc_file ? -2 : ORIGINAL_NAME(fileno)(stream);
}

#ifdef __APPLE__
FILE *fopen_DARWIN_EXTSN(const char *restrict, const char *restrict) __DARWIN_EXTSN(fopen);

__attribute__((used, section("__DATA,__interpose"))) static struct {
	FILE *(*overridden_fopen)(const char *restrict, const char *restrict);
	FILE *(*fopen)(const char *restrict, const char *restrict);
} fopen_overrides[] = {
    {overridden_fopen, fopen},
    {overridden_fopen, fopen_DARWIN_EXTSN},
};

__attribute__((used, section("__DATA,__interpose"))) static struct {
	int (*original_fclose)(FILE *);
	int (*fclose)(FILE *);
} fclose_overrides[] = {
    {overridden_fclose, fclose},
};

__attribute__((used, section("__DATA,__interpose"))) static struct {
	int (*original_fileno)(FILE *);
	int (*fileno)(FILE *);
} fileno_overrides[] = {
    {overridden_fileno, fileno},
};
#endif
