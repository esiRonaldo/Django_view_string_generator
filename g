def cssTheme_createWithModelForm(request, css_theme_id=None):
    @register.filter
    def get_item(dictionary, key):
        return dictionary.get(key)

    @register.filter
    def get_key(dictionary,value):
        key=dictionary.index(value)
        return key

    initial = {}
    if css_theme_id:
        css_theme = CssTheme.objects.get(pk=css_theme_id)
        initial = css_theme.template

    form = ThemeForm(request.POST or None, initial=initial)
# font achen, empty scape char

    def toString(css_theme):
        FontFamily:['BebasBold','BebasNeue','Inkfree','ThinkingOfBetty','Montserrat-Semibold']
        main_css_variables_string = ":root {\\r\\n"+"\n"
        used_fonts=set()
        font_uri=set()

        for line in form.Component_Dict:
            val= form.default_css_vars_dic.get(line)
            if isinstance(val, dict):
                media = CssThemeMedia.objects.get(pk=css_theme.template[line])
                if media.type == CssThemeMedia.MediaType.FONT.value:
                        font_family=media.name
                        used_fonts.add(font_family)
                        font_family_id=media.id
                        font_uri.add(font_family_id)
        for font,font_id in zip(used_fonts,font_uri):
            if font_id==27 or font_id==28:
                main_css_variables_string+="@#font-face {\\r\\n\\tfont-family: '"+font+"' ;"+"\\r\\n\\tsrc: url('/orderkiosk/api/css_theme_media/"+str(font_id)+"/get_file_by_id/') format('truetype')\\r\\n;\\r\\n}\\r\\n\\r\\n"+"\n"
            else:
                main_css_variables_string += "@#font-face {\\r\\n\\tfont-family: '" + font + "' ;" + "\\r\\n\\tsrc: url('/orderkiosk/api/css_theme_media/" + str(font_id) + "/get_file_by_id/');\\r\\n;\\r\\n}\\r\\n\\r\\n"+"\n"

        for cssDef in form.Component_Dict:
            CompNameList = form.Component_Dict.get(cssDef)
            value_description = form.default_css_vars_dic.get(cssDef)
            if isinstance(value_description, dict):
                media = CssThemeMedia.objects.get(pk=css_theme.template[cssDef])
                if media.type == CssThemeMedia.MediaType.FONT.value:
                    css_value = "{0}".format(media.name)
                else:
                    css_value = "url(\"/orderkiosk/api/css_theme_media/"+str(media.id)+"/get_file_by_id/\")"
            else:
                css_value = css_theme.template[cssDef]

            for CompName in CompNameList:
                main_css_variables_string += "--" + CompName + css_value + ";" + "\\r\\n"+"\n"

        main_css_variables_string += "}"
        print(main_css_variables_string)
        return main_css_variables_string

    if request.method=='POST':
        if form.is_valid():
            if not css_theme_id: #create
                css_theme = CssTheme()
            template_data = form.cleaned_data
            for field, description in form.default_css_vars_dic.items():
                if isinstance(description, dict):
                    if description.get("type", "font") == "font":
                        template_data[field] = template_data[field].id
                    elif description.get("type", "image") == "image":
                        template_data[field] = template_data[field].id
                    else:
                        pass
            css_theme.template = template_data
            css_string_value = toString(css_theme)
            css_theme.css_vars = css_string_value
            css_theme.save()
            return redirect(reverse("edit-form", args=[css_theme.id]))

    return render(request,'admin/orderkiosk/csstheme/createWithModelForm.html', {'form':form, 'edit': css_theme_id })
