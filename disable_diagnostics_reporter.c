#include <stdbool.h>

bool CRIsSeedBuild(void);

bool overridden_CRIsSeedBuild(void) {
	return false;
}

__attribute__((used, section("__DATA,__interpose"))) static struct {
	bool (*overridden_CRIsSeedBuild)(void);
	bool (*CRIsSeedBuild)(void);
} CRIsSeedBuild_overrides[] = {
    {overridden_CRIsSeedBuild, CRIsSeedBuild},
};
