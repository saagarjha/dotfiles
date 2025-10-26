#include <stdbool.h>
#include <string.h>

bool os_variant_has_internal_content(const char *subsystem);

bool overridden_os_variant_has_internal_content(const char *subsystem) {
	if (subsystem && !strcmp(subsystem, "com.apple.dt.Xcode")) {
		return true;
	} else {
		return os_variant_has_internal_content(subsystem);
	}
}

__attribute__((used, section("__DATA,__interpose"))) static struct {
	bool (*overridden_os_variant_has_internal_content)(const char *);
	bool (*os_variant_has_internal_content)(const char *);
} os_variant_has_internal_content_overrides[] = {
    {overridden_os_variant_has_internal_content, os_variant_has_internal_content},
};
