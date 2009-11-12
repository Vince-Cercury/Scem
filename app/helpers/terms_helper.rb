module TermsHelper
  def display_classic_date(date)
    date.strftime("%A, %d-%m-%Y")
  end

  def display_simpliest_date(date)
    this_year = Date.today.strftime("%y")
    this_month = Date.today.strftime("%m")
    if date.strftime("%y") == this_year && date.strftime("%m") == this_month
      clever_date = l(date,:format => 'day_name_and_number')
    end
    if date.strftime("%y") == this_year && date.strftime("%m") != this_month
      clever_date = l(date,:format => 'day_name_and_number_and_month')
    end
    if date.strftime("%y") != this_year && date.strftime("%m") == this_month
      clever_date = l(date,:format => 'day_name_and_number_and_month_and_year')
    end
    if date.strftime("%y") != this_year && date.strftime("%m") != this_month
      clever_date = l(date,:format => 'day_name_and_number_and_month_and_year')
    end
    return clever_date
  end

  def display_nice_time(date)
    date.strftime("%H:%M")
  end

  def display_date_box(date)
    today = Date.today
    tomorrow = Date.today + 1
    yesterday = Date.today - 1


    if(date.to_date == today)
      the_day = t('Today')
    end
    if(date.to_date == tomorrow)
      the_day = t('Tomorrow')
    end
    if(date.to_date == yesterday)
      the_day = t('Yesterday')
    end

    if (date.to_date == today or date.to_date == tomorrow or date.to_date == yesterday)
      result =the_day
      result +='<br />'+t("at")+' '
      result += date.strftime("%H:%M")
    end



    if (date.to_date != today and date.to_date != tomorrow and date.to_date != yesterday)
      result = t("The+space")+ display_simpliest_date(date)
      result += ' '+t("at")+' '
      result += date.strftime("%H:%M")
    end

    return result
  end

  def display_term_box(start_at, end_at)
    today = Date.today
    tomorrow = Date.today + 1
    yesterday = Date.today - 1


    if(start_at.to_date == today)
      the_day = t('Today')
    end
    if(start_at.to_date == tomorrow)
      the_day = t('Tomorrow')
    end
    if(start_at.to_date == yesterday)
      the_day = t('Yesterday')
    end

    if (start_at.to_date == today or start_at.to_date == tomorrow or start_at.to_date == yesterday) && end_at.to_date == start_at.to_date
      result =the_day
      result +='<br />'+t("from")+' '
      result += start_at.strftime("%H:%M")
      result += ' '+t("until")+' '
      result += end_at.strftime("%H:%M")
    end


    if (start_at.to_date == today or start_at.to_date == tomorrow or start_at.to_date == yesterday) && end_at.to_date != start_at.to_date
      result =the_day
      result +=' '+t("at")+' '
      result += start_at.strftime("%H:%M")
      result += ' '+t("to")+' '
      result += display_simpliest_date(end_at)
      result += ' '+t("at")+' '
      result += end_at.strftime("%H:%M")
    end

    if (start_at.to_date != today and start_at.to_date != tomorrow and start_at.to_date != yesterday)  && end_at.to_date == start_at.to_date
      result = t("The+space")+ display_simpliest_date(start_at)
      result += ' '+t("from")+' '
      result += start_at.strftime("%H:%M")
      result += ' '+t("until")+' '
      result += end_at.strftime("%H:%M")
    end

    if (start_at.to_date != today and start_at.to_date != tomorrow and start_at.to_date != yesterday)  && end_at.to_date != start_at.to_date
      result =t("From")+' '
      result += display_simpliest_date(start_at)
      result += ' '+t("at")+' '
      result += start_at.strftime("%H:%M")
      result += ' '+t("to")+' '
      result += display_simpliest_date(end_at)
      result += ' '+t("at")+' '
      result += end_at.strftime("%H:%M")
    end
    
    return result
  end
end
