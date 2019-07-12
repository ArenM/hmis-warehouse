###
# Copyright 2016 - 2019 Green River Data Analysis, LLC
#
# License detail: https://github.com/greenriver/hmis-warehouse/blob/master/LICENSE.md
###

class TokenMailer < DatabaseMailer

  def note_added user, token
    @token = token
    @user = user
    mail(to: @user.email, subject: "Client note added")

  end
end
