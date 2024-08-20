#include <stdio.h>

#include "WolframLanguageRuntimeV1SDK.h"

int main(int argc, char *argv[]) {
	char *result;

	if (argc != 2) {
		printf("%s\n", "Usage: ./transliterate-c \"input\"");
		return 1;
	}

	wlr_runtime_conf conf;
	wlr_InitializeRuntimeConfiguration(&conf);
	conf.containmentSetting = WLR_UNCONTAINED;

	wlr_err_t err0 = WLR_SDK_START_RUNTIME(WLR_EXECUTABLE, WLR_LICENSE_OR_SIGNED_CODE_MODE, "/Applications/Wolfram.app/Contents", &conf);
		if (err0 != WLR_SUCCESS) {
		printf("%s (error: %d)\n", "SDK failed to start correctly", err0);
		return 1;
	}

	wlr_expr head = wlr_Symbol("Transliterate");
	wlr_expr arg = wlr_String(argv[1]);
	wlr_expr normal = wlr_E(head, arg);
	wlr_expr res = wlr_Eval(normal);
	wlr_err_t err = wlr_StringData(res, &result, NULL);
	if (err != WLR_SUCCESS) {
		return 1;
	}

	printf("%s\n", result);

	wlr_Release(result);

	return 0;
}