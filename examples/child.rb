require_relative "../lib/tty/logger"

logger = TTY::Logger.new(fields: {app: "parent", env: "prod"})
child_logger = logger.copy(app: "child") do |config|
  config.filters = ["logging"]
end

logger.info("Parent logging")
child_logger.warn("Child logging")
