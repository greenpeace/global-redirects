# P4 Global Redirects

Interim solution for providing SSL-enabled redirects from P4 infrastructure.

## Requirements

* [yamllint](http://www.yamllint.com/)
* [jq](https://stedolan.github.io/jq/)
* [make](https://www.gnu.org/software/make/) - Instructions for installing make vary, for OSX users `xcode-select --install` might work.

## Howto

Modify [sites.json](sites.json) to include *at least* the `from` and `to` fields, like so:

```json
{
  "from": "www.greenpeace.org.au",
  "to": "www.greenpeace.org/australia/"
}
```

It's highly recommended to include ownership details for future accountability.

Additional fields are optional, see [sites.example.json](sites.example.json) for possibilities.

Ignore protocols, ingresses respond on both HTTP and HTTPS, but will only redirect to HTTPS targets by design.

Once you've edited [sites.json](sites.json), run `make lint` to confirm syntax validity, then commit and push changes to the `develop` branch of this repository. Create a PullRequest from develop to master, and assign a reviewer to confirm sanity.

Once the PR is approved and merged to master, CircleCI will then deploy changes automagically, view status here: [https://circleci.com/gh/greenpeace/global-redirects](https://circleci.com/gh/greenpeace/global-redirects)

Once successfully deployed, test redirection is succesful via local hostfile manipulate, then update production DNS records accordingly.

```bash
# Planet4 Production IP:
dig +short prod.p4.greenpeace.org
```
