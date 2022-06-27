class ErrorsController < ApplicationController
  def show
    # config.exceptions_appで補足した例外をApplicationControllerにraiseする
    raise request.env['action_dispatch.exception']
  end
end
