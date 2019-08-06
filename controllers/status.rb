# frozen_string_literal: true

module Controllers
  # Controller used to generate the status route used by the vigilante
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Status < Arkaan::Utils::Controllers::Checked
    declare_status_route
  end
end
