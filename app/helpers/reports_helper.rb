module ReportsHelper
  def tree_class id
    if params['controller'] == 'reports'
      if params['action'] == 'show' and id == 'resources'
        "active"
      end
    end
  end
end
