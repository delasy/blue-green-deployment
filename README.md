# blue-green-deployment

This action provides the following functionality for GitHub Actions users:

- Blue/Green deployment for PM2 running on Ubuntu

> NOTE: For this GitHub Action to work you should have NGINX configuration containing
> `proxy_pass http://localhost:3000;` (see [nginx.conf.example](nginx.conf.example)).

> NOTE: For this GitHub Action to work you should have PM2 ecosystem configuration containing
> `$TARGET` and `$TARGET_PORT` (see [ecosystem.config.js.example](ecosystem.config.js.example)).

> NOTE: For this GitHub Action to work you should have remote directories
> `/apps/$NAME/blue` and `/apps/$NAME/green` created.

## Input

See [action.yml](action.yml) for more detailed information.

| Name             | Description                                 | Example    | Default Value |
| ---------------- | ------------------------------------------- | ---------- | ------------- |
| name             | Name of the project, usually project domain | delasy.com |               |
| host             | Remote host address                         | 1.1.1.1    |               |
| port             | Remote port number                          | 22         | 22            |
| username         | Remote username                             | ubuntu     |               |
| password         | Remote password                             |            |               |
| private-key      | Contents of private SSH key                 |            |               |
| source           | Source directory path                       | ./build    |               |
| blue-port        | NGINX blue port                             | 3000       | 3000          |
| green-port       | NGINX green port                            | 3001       | 3001          |
| strip-components | Remove specified number of leading path     | 1          | 1             |
|                  | elements when unpacking tar file            |            |               |

## Usage

Basic example:

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: delasy/blue-green-deployment@v1
    with:
      name: example.com
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      password: ${{ secrets.PASSWORD }}
      source: ./build
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE.txt)
