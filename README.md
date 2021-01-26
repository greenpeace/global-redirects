[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fgreenpeace%2Fglobal-redirects.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fgreenpeace%2Fglobal-redirects?ref=badge_shield)  [![Greenpeace](https://circleci.com/gh/greenpeace/global-redirects.svg?style=shield)](https://circleci.com/gh/greenpeace/global-redirects)

![Planet4](./p4logo.png)

# P4 Global Redirects

Solution for providing SSL-enabled redirects from P4 infrastructure.  In order to add redirects here you need to control (or have updated the DNS records) to point to this corresponding Nginx ingress so the ACME validation is successful (https://github.com/greenpeace/global-redirects-nginx-ingress/blob/develop/env/prod/values.yaml))

## Optional Requirements

* [yamllint](http://www.yamllint.com/)
* [jq](https://stedolan.github.io/jq/)
* [make](https://www.gnu.org/software/make/) - Instructions for installing make vary, for OSX users `xcode-select --install` might work.

## Deployment

Modify [prod.sites.json](prod.sites.json) to include these fields, ensuring the owner is the current DNS (maintainer) owner:

```json
{
  "owners": [
    {
     "name": "GPI Ops",
     "emal": "global-it-operation@greenpeace.org",
     "unit": "GPI Operations"
    }
  ],
  "from": "www.greenpeace.my",
  "to": "www.greenpeace.org/mycountry"
}
```

When entering URLS, ignore protocols as ingresses respond on both HTTP and HTTPS, but will only redirect to HTTPS targets by design.

Once you've edited [prod.sites.json](prod.sites.json), commit and push changes to the `develop` branch of this repository. This will run a prodprep job to confirm syntax.  Create a Pull Request from develop to master, and assign a reviewer to confirm sanity.

Once the PR is approved and merged to master, CircleCI will then deploy changes automagically, view status here: [https://circleci.com/gh/greenpeace/global-redirects](https://circleci.com/gh/greenpeace/global-redirects)

Once successfully deployed, test redirection and certificate issuance is successful (via local hostfile manipulate if necessary).

If your certificate is not generated you can check this guide on how to troubleshoot: (https://www.notion.so/p4infra/Redirects-3a5488abbb784c9e911e6b6311870eae)


```bash
# Planet4 Production IP:
dig +short prod.p4.greenpeace.org
```

### Usage
 - Clone the repo to access makefile commands via cli that are not executed via CircleCI:
   - `make list` - <em> List all ingresses </em>
   - `make destroy` - <em> destroy all deployed ingresses </em> <strong> CAUSES DATA LOSS </strong>


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fgreenpeace%2Fglobal-redirects.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fgreenpeace%2Fglobal-redirects?ref=badge_large)
