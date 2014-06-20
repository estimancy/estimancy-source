
module ControllerHelpers
  ###def sign_in(user = double('user'))
  def sign_in(user = User.first)
    if user.nil?
      request.env['warden'].stub(:authenticate!).
      and_throw(:warden, {:scope => :user})
      allow(controller).to receive(:current_user) { nil }
    else
      request.env['warden'].stub :authenticate! => user
      allow(controller).to receive(:current_user) { user }
    end
  end
end



