# gitlab-runner-with-tools
Gitlab runner with ssh and php preinstalled

## Docker-compose block
  runner:
    image: dr4g0nsr/gitlab-runner:latest
    restart: always
    hostname: runner
    container_name: runner
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data/gitlab-runner-config:/etc/gitlab-runner
      - ./data/gitlab-runner-home:/home/gitlab-runner

In /data/gitlab-runner-config there is toml with generated config.

In /data/gitlab-runner-home there is a workdir with ssh keys in .ssh. Use this to deploy to production, locally you will find it in ./data/gitlab-runner-home/.ssh.

Keys are generated on first start and will regenerate if deleted or volume changed (missing in any case).

## .gitlab-ci.yml deployment
For rsync deployment i use this:
- rsync -e "ssh -o StrictHostKeyChecking=no" -av --exclude 'wp-config.php' . root@1.2.3.4:/var/www/html/wordpress
For SSH command(s):
- ssh -o StrictHostKeyChecking=no root@1.2.3.4 'chown www-data:www-data /var/www/html/wordpress -R'
