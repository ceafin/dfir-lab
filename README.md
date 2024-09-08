# Disposable DFIR lab

Looking to create a Terraform "disposable" deployable DFIR lab set up to save on buying local hardware for play.

## Hosts

This will create two hosts:
* a [SIFT workstation](https://www.sans.org/tools/sift-workstation/), and
* a Windows Server 2016 host

## Secret Variables

In an effort to make sure no one accidently hardcodes their IPs or Hostnames into their project. I have Terraform pull hostnames in through a list before deploying. The user will need to create their own `secrets.tfvars` file to feed into the script, via:

```shell
terraform apply -var-file="secrets.tfvars"
```

And the contents of the file should have any number of source addresses you wish to have access to your micro lab.

secrets.tfvars:
```ini
my_private_local_fqdns = ["my.network.net", "my.otherplace.com"]
```

### But I Don't Have a Static IP!

If you already have a domain, you can use Cloudflare as a free Dynamic DNS host. _(If not, go buy one with Cloudflare, and pick a cheap TLD if need be.)_

There are lots of ddns clients out there to help, and pfSense/OPNsense both have packages for this as well. So if you're building this at home off of an IP address that changes, set Cloudflare up, and then as your DDNS host A record to the `my_private_local_fqdns` variable.

## Extra Instructions

This will just set up the two hosts with a basic Security Group assignment and IGW for you to get started. Each host will still need a little massaging to get comfortable. As I figure that out, I'll update here.