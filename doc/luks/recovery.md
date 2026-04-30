# Split and Combine Recovery Secret

In case our TPM or Tang server isn't working and we need another way to unlock a device, we can use a recovery passphrase shared between multiple people using Shamir's Shared Secret.

## Creating a Secret

First we need to create a random secret key using openssl, where the number is the length:
```sh
openssl rand -base64 64
```

Then add the secret to you LUKS device:

```sh
sudo cryptsetup luksAddKey /dev/sdX
```

## Splitting the secret

Then we use `ssss` to split the secret in `n` parts where a minimum of `t` shares are necessary to find the secret.

Download `ssss`:

```sh
apt-get install ssss
```

Split the secret, you will be prompted to enter the random key:
```sh
ssss-split -t 3 -n 5 -q
```

You will then see `n` different shares than you must save between `n` people.

> [!IMPORTANT]
> Do not lose these shares ! If more than `n - t` people lose their shares, the secret will be lost !

## Combining secrets

If the day comes where you need to use the recovery passphrase, you can use the `ssss-combine` command, where `t` is the minimum amount of shares you defined before:

```sh
sss-combine -t 3
```

If the shares are correct, the randomly generated secret will be shown.