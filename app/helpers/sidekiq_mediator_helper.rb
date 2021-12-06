module SidekiqMediatorHelper
  def perform_async(klass, *args)
    #args.push(@current_organization.name, current_user.login_name)
    args.prepend(@current_organization.name, current_user.login_name)
    klass.send(:perform_async, *args)
  end
end