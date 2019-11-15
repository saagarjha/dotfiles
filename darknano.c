#define _GNU_SOURCE

#include <dlfcn.h>
#include <stdbool.h>
#include <string.h>

#ifdef __APPLE__
#define OVERRIDE_NAME(function) overridden_##function
#define ORIGINAL_NAME(function) function
#else
#define OVERRIDE_NAME(function) function
#define ORIGINAL_NAME(function) original_##function
#endif

int (*original_strncasecmp)(const char *, const char *, size_t);
int (*original_strcasecmp)(const char *, const char *);

__attribute__((weak)) const char *getprogname();
__attribute__((weak)) extern char *program_invocation_short_name;

bool initialized = false;

bool should_inject = false;

static void *find_libc_symbol(const char *name) {
	void *symbol = dlsym(RTLD_NEXT, name);
	if (symbol) {
		return symbol;
	} else {
		// If dlsym failed with "RTLD_NEXT used in code not dynamically loaded"
		Dl_info info;
		dladdr(strcmp /* Something inside of libc */, &info);
		return dlsym(dlopen(info.dli_fname, RTLD_LAZY | RTLD_NOLOAD), name);
	}
}

static void darknano_init() {
	should_inject = (getprogname && !strcmp(getprogname(), "nano")) ||
	                (&program_invocation_short_name && !strcmp(program_invocation_short_name, "nano"));
	original_strncasecmp = find_libc_symbol("strncasecmp");
	original_strcasecmp = find_libc_symbol("strcasecmp");
	initialized = true;
}

// I can't figure out how to make darknano_init be called before any other
// library's constructor, so just force initialization on first call to the
// functions we interpose. (If we don't do this, certain applications will call
// these functions in their constructors and the "original" functions will never
// be set.)
#define ENSURE_INITIALIZATION() \
	if (!initialized) {         \
		darknano_init();        \
	}

int OVERRIDE_NAME(strncasecmp)(const char *s1, const char *s2, size_t n) {
	ENSURE_INITIALIZATION();
	if (should_inject && n == 6 && !strncmp(s2, "bright", n)) {
		return !0;
	} else {
		return ORIGINAL_NAME(strncasecmp)(s1, s2, n);
	}
}

int OVERRIDE_NAME(strcasecmp)(const char *s1, const char *s2) {
	ENSURE_INITIALIZATION();
	if (should_inject && !ORIGINAL_NAME(strncasecmp)(s1, "bright", 6)) {
		s1 += 6;
	}
	return ORIGINAL_NAME(strcasecmp)(s1, s2);
}

#ifdef __APPLE__
__attribute__((used, section("__DATA,__interpose"))) static struct {
	int (*overridden_strncasecmp)();
	int (*strncasecmp)();
} overrides[] = {
    {overridden_strncasecmp, strncasecmp},
    {overridden_strcasecmp, strcasecmp},
};
#endif
