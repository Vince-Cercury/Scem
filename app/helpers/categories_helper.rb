module CategoriesHelper
  def categories_to_display()
    @categories = Category.find_all_by_to_display(true, :order => 'name DESC')
  end

  def categories_not_to_display()
    @categories = Category.find_all_by_to_display(false, :order => 'name DESC')
  end
end
