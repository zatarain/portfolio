job "certbot" {
  datacenters = ["dc1"]
  type        = "batch"

  periodic {
    crons            = ["45 9 * * *"]
    prohibit_overlap = true
    time_zone        = "Europe/London"
  }

  group "ssl-certificates" {
		task "setup" {
			driver = "raw_exec"
			config {
				command = "sh"
				args    = ["-c", "exec cp -f $NOMAD_TASK_DIR/certbot-deploy /usr/local/bin/certbot-deploy"]
			}

			template {
				data        = file("nomad/jobs/scripts/certbot-deploy.sh")
				destination = "local/certbot-deploy"
				perms       = "755"
			}

			lifecycle {
				hook    = "prestart"
				sidecar = false
			}

			resources {
				cpu    = 50
				memory = 64
			}
		}

    task "renew" {
      driver = "raw_exec"

      config {
        command = "sh"
        args    = ["-c", "exec sudo certbot renew --deploy-hook certbot-deploy"]
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }
  }

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "freebsd"
  }
}
