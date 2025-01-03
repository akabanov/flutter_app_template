# Prerequisites

These are configured once (not per project).

## Tools

[Install Flutter and Android Studio](https://docs.flutter.dev/get-started/install/linux/android),
if you haven't done it yet.

Make sure you have installed:

```shell
sudo apt-get install curl sed git ruby openjdk-17-jdk
```

Make sure you have correctly set `JAVA_HOME`:

```shell
# ~/.bash_profile
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

## Ruby

Make sure your gems live in your local user space to avoid unexpected file permission issues:

```shell
# ~/.bash_profile
export GEM_HOME="$HOME/.gems"
export PATH="$HOME/.gems/bin:$PATH"
```

## Fastlane

Fastlane is a command-line tool that automates common tasks in iOS and Android development workflows,
such as building, testing, code signing, and deploying apps to the App Store and Play Store.

```shell
gem install fastlane
```

## GitHub CLI

Install [GitHub CLI](https://github.com/cli/cli/blob/trunk/docs/install_linux.md).

In order for `nuke` script to work, the CLI must be authorised to `delete_repo`.

## Slack

Slack is a real-time messaging platform that, among other things,
integrates with CI/CD tools (Codemagic, Fastlane) to provide instant notifications
about app's build status, test results, and deployments.

Free tier provides message retention for 90 days and allows integration with up to 10 applications,
which is suitable for the purpose CI/CD notifications.

[Create a Slack account](https://slack.com/get-started).

Install local Slack app (and maybe mobile app as well):

```shell
sudo snap install slack
```

## Apple

Create and download [App Store Connect API (team) key](https://appstoreconnect.apple.com/access/integrations/api)
for CI/CD integration.

See the [roles definition](https://developer.apple.com/help/account/manage-your-team/roles/)
to get the idea which role to use, use Admin if feeling adventurous.

Create the following env variables:

```shell
export APP_STORE_CONNECT_ISSUER_ID=...
export APP_STORE_CONNECT_KEY_IDENTIFIER=...
export APP_STORE_CONNECT_PRIVATE_KEY=$(cat /path/to/your/AuthKey.p8)
```

## Codemagic

### Integrations

Make sure you have "Codemagic CI/CD" app in your [GitHub Applications](https://github.com/settings/installations).

Go to [your account setting](https://codemagic.io/teams) and set up integrations:

- GitHub
- Slack
- (Apple) Developer Portal (use the key from above)

Create an env variable with your Codemagic API key:

```shell
export CODEMAGIC_API_TOKEN=...
```

### Code signing - iOS

Generate iOS code signing certificate (same page, "codemagic.yaml settings -> code signing identities").

Most teams working with CI/CD only need the **Distribution** certificate
since test builds typically go through TestFlight.
You'd only need both if you have a specific requirement
for installing development builds directly on devices outside of TestFlight.

Call it `distribution_certificate`.

Note the reference name, password, and download the certificate.

You can find the generated certificates at your Apple Dev Account
[Certificates page](https://developer.apple.com/account/resources/certificates/list).

### Code signing - Android

**TODO**

## Google Cloud

Integration with Google Cloud is needed if you are going to use any of their services,
for example, Firebase Test Lab.

[Create a billing account](https://console.cloud.google.com/billing) if you don't have a suitable one.

Place your billing account to `GCLOUD_BILLING_ACCOUNT_ID` if you want
the project setup script to use it as a fallback option.

Then follow official `gcloud` CLI [installation instructions](https://cloud.google.com/sdk/docs/install-sdk#deb).

## Shorebird

Shorebird is a tool that enables over-the-air (OTA) code updates for Flutter apps,
allowing developers to patch their production apps without going through the app store review process.

[Create a dev account with Shorebird](https://console.shorebird.dev/login) if you haven't yet.

[Install Shorebird CLI](https://docs.shorebird.dev/).

## Shell aliases

Here are some aliases you may find useful.
Add them to your `~/.bashrc`:

```shell
alias ba='dart run build_runner build && git add -A .'
alias fa='flutter pub add '
alias ft='flutter test'
alias fit='flutter drive --driver=test_driver/integration_test.dart --target=integration_test/all_tests.dart'
alias frl='flutter run -d "linux"'
```

My personal:

```shell
alias frm='flutter run -d "moto g24"'
```