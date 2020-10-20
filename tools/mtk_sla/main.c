#include <openssl/rsa.h>
#include <openssl/pem.h>
#include "SLA_Challenge.h"
#include <stdio.h>
#include <string.h>
#define PUBLICKEY "rsa_public_key.pem"

int main() {
	unsigned char *source = (unsigned char*) "1234567890abcdef";
	printf("source %s\n", source);
	unsigned char* pp_challenge_out = 0;
	unsigned int p_challenge_out_len = 0;
	int ret = SLA_Challenge(0, source, strlen(source), &pp_challenge_out, &p_challenge_out_len);
	if (ret == 0) {
		FILE *fp = NULL;
		RSA *publicRsa = NULL;
		if ((fp = fopen(PUBLICKEY, "r")) == NULL)
		{
			printf("public key path error\n");
			return -1;
		}

		if ((publicRsa = PEM_read_RSA_PUBKEY(fp, NULL, NULL, NULL)) == NULL)
		{
			printf("PEM_read_RSA_PUBKEY error\n");
			return -1;
		}
		fclose(fp);
		int rsa_len = RSA_size(publicRsa);
		unsigned char *decryptMsg = (unsigned char *)malloc(rsa_len);
		memset(decryptMsg, 0, rsa_len);

		int mun =  RSA_public_decrypt(p_challenge_out_len, pp_challenge_out, decryptMsg, publicRsa, RSA_PKCS1_PADDING);

		if ( mun < 0)
			printf("RSA_private_decrypt error\n");
		else
			printf("RSA_private_decrypt %s\n", decryptMsg);
	}

	SLA_Challenge_END(0, 0);
	return 0;
}
