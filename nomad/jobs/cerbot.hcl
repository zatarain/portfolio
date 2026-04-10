job "certbot-renew" {
  datacenters = ["dc1"]
  type        = "batch"

  periodic {
    crons            = ["0 3 * * *"]
    prohibit_overlap = true
    time_zone        = "Europe/London"
  }

  group "certbot" {
		task "setup" {
			driver = "raw_exec"
			config {
				command = "sh"
				args    = ["-c", "exec cp -f $NOMAD_TASK_DIR/certbot-deploy.sh /usr/local/bin/certbot-deploy.sh"]
			}

			template {
				data        = file("nomad/jobs/scripts/certbot-deploy.sh")
				destination = "local/certbot-deploy.sh"
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
      user   = "root"

      env {
        PATH = "/usr/local/bin:/usr/bin:/bin"
      }

      config {
        command = "sh"
        args    = ["-c", "exec certbot renew --deploy-hook /usr/local/bin/certbot-deploy.sh"]
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
