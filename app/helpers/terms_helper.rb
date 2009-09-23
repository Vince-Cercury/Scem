module TermsHelper
  def display_classic_date(date)
    date.strftime("%A, %d-%m-%Y")
  end

  def display_simpliest_date(date)
    this_year = Date.today.strftime("%y")
    this_month = Date.today.strftime("%m")
    if date.strftime("%y") == this_year && date.strftime("%m") == this_month
      clever_date = date.strftime("%A %d")
    end
    if date.strftime("%y") == this_year && date.strftime("%m") != this_month
      clever_date = date.strftime("%d %B")
    end
    if date.strftime("%y") != this_year && date.strftime("%m") == this_month
      clever_date = date.strftime("%d %B %Y")
    end
    if date.strftime("%y") != this_year && date.strftime("%m") != this_month
      clever_date = date.strftime("%d %B %Y")
    end
    return clever_date
  end

  def display_nice_time(date)
    date.strftime("%H:%M")
  end

  def display_term_box(start_at, end_at)
    today = Date.today
    tomorrow = Date.today + 1
    yesterday = Date.today - 1


    if(start_at.to_date == today)
      the_day = 'Today'
    end
    if(start_at.to_date == tomorrow)
      the_day = 'Tomorrow'
    end
    if(start_at.to_date == yesterday)
      the_day = 'Yesterday'
    end

    if (start_at.to_date == today or start_at.to_date == tomorrow or start_at.to_date == yesterday) && end_at.to_date == start_at.to_date
      result =the_day
      result +='<br />from '
      result += start_at.strftime("%H:%M")
      result += ' until '
      result += end_at.strftime("%H:%M")
    end


    if (start_at.to_date == today or start_at.to_date == tomorrow or start_at.to_date == yesterday) && end_at.to_date != start_at.to_date
      result =the_day
      result +=' at '
      result += start_at.strftime("%H:%M")
      result += ' until '
      result += display_simpliest_date(end_at)
      result += ' at '
      result += end_at.strftime("%H:%M")
    end

    if (start_at.to_date != today and start_at.to_date != tomorrow and start_at.to_date != yesterday)  && end_at.to_date == start_at.to_date
      result = "the "+ display_simpliest_date(start_at)
      result += ' from '
      result += start_at.strftime("%H:%M")
      result += ' until '
      result += end_at.strftime("%H:%M")
    end

    if (start_at.to_date != today and start_at.to_date != tomorrow and start_at.to_date != yesterday)  && end_at.to_date != start_at.to_date
      result ='From '
      result += display_simpliest_date(start_at)
      result += ' at '
      result += start_at.strftime("%H:%M")
      result += ' until '
      result += display_simpliest_date(end_at)
      result += ' at '
      result += end_at.strftime("%H:%M")
    end
    
    return result
  end
end
