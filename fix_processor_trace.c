#include <stdint.h>
#include <unistd.h>

#define CS_OPS_STATUS 0
#define CS_GET_TASK_ALLOW 0x00000004

int csops(pid_t pid, unsigned int ops, void *useraddr, size_t usersize);

int overridden_csops(pid_t pid, unsigned int ops, void *useraddr, size_t usersize) {
	int result = csops(pid, ops, useraddr, usersize);
	if (ops == CS_OPS_STATUS) {
		*(uint32_t *)useraddr |= CS_GET_TASK_ALLOW;
	}
	return result;
}

__attribute__((used, section("__DATA,__interpose"))) static struct {
	int (*overridden_csops)(pid_t, unsigned int, void *, size_t);
	int (*csops)(pid_t, unsigned int, void *, size_t);
} fopen_overrides[] = {
    {overridden_csops, csops},
};
