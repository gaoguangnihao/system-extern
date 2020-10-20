#include <openssl/rsa.h>
#include <openssl/pem.h>
#include "SLA_Challenge.h"
#include "stdio.h"
#include <string.h>

#define PRIVATEKEY "rsa_private_key.pem"

int SLA_Challenge(void *usr_arg, const unsigned char *p_challenge_in,
		unsigned int challenge_in_len, unsigned char **pp_challenge_out,
		unsigned int *p_challenge_out_len) {

	printf("SLA_Challenge\n");
	FILE *fp = NULL;
	RSA *privateRsa = NULL;

	if ((fp = fopen(PRIVATEKEY, "r")) == NULL) {
		printf("private key path error\n");
		return -1;
	}

	if ((privateRsa = PEM_read_RSAPrivateKey(fp, NULL, NULL, NULL)) == NULL) {
		printf("PEM_read_RSAPrivateKey error\n");
		return -1;
	}
	fclose(fp);

	printf("p_challenge_in %d\n", strlen(p_challenge_in));

	int rsa_len = RSA_size(privateRsa);
    printf("rsa_len 1: %d\n", rsa_len);

	unsigned char *encryptMsg = (unsigned char*)malloc(rsa_len);
	memset(encryptMsg, 0, rsa_len);

	if (RSA_private_encrypt(challenge_in_len, p_challenge_in, encryptMsg, privateRsa,
			RSA_PKCS1_PADDING) < 0) {//fix-me
		printf("RSA_private_encrypt error\n");
		return -1;
	} else {
		printf("encryptMsg: %d\n", rsa_len);
		*p_challenge_out_len = rsa_len;
		*pp_challenge_out = encryptMsg;
	}

	RSA_free(privateRsa);
	return 0;

}
int SLA_Challenge_END(void *usr_arg, unsigned char *p_challenge_out) {

	printf("SLA_Challenge_END\n");

	free(p_challenge_out);

	return 0;

}
