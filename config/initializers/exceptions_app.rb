# コントローラの外側で発生した例外を補足する
Rails.configuration.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }
