// { RGS Лунякин Иван 07.10.2015 13:53:54

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ТекПроект = Параметры.Проект;
	
	// { RGS Лунякин Иван 27.10.2015 12:51:08 
	Администратор = Параметры.Администратор;
	// } RGS Лунякин Иван 27.10.2015 12:51:08
	
	// { RGS Глебов Дмитрий 14.09.2016  - S-I-0001846 
	Параметры.Свойство("МожноВыбиратьГруппы",МожноВыбиратьГруппы);
	ЗакрыватьПриВыборе = Истина;
	// } RGS Глебов Дмитрий 14.09.2016  - S-I-0001846 

	// { RGS Лунякин Иван 03.11.2015 16:29:30 
	ПолучитьНастройкиФормы();
	// } RGS Лунякин Иван 03.11.2015 16:29:30
	
	// { RGS Глебов Дмитрий 14.09.2016  - S-I-0001846
	ОчиститьСписокВыбора();
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ДеревоЗначений = ОбработкаОбъект.ДеревоПредопределенныхТем(ТекПроект);
	ЗначениеВРеквизитФормы(ДеревоЗначений, "СписокТемСИерархией");
	// } RGS Глебов Дмитрий 14.09.2016 - S-I-0001846
		
КонецПроцедуры

// { RGS Лунякин Иван 03.11.2015 16:26:16

&НаСервере
Процедура ПолучитьНастройкиФормы()

	СтруктураНастроекФормы = ХранилищеНастроекДанныхФорм.Загрузить(ЭтаФорма.ИмяФормы, "НастройкаФорм");
	Если СтруктураНастроекФормы <> Неопределено Тогда
	   ХранилищеСистемныхНастроек.Сохранить(ЭтаФорма.ИмяФормы + "/НастройкиФормы",,СтруктураНастроекФормы);
	КонецЕсли;
	СтруктураНастроекОкна = ХранилищеНастроекДанныхФорм.Загрузить(ЭтаФорма.ИмяФормы, "НастройкаОкна");
	Если СтруктураНастроекФормы <> Неопределено Тогда
	   ХранилищеСистемныхНастроек.Сохранить(ЭтаФорма.ИмяФормы + "/НастройкиОкна",,СтруктураНастроекОкна);
	КонецЕсли;

КонецПроцедуры

// } RGS Лунякин Иван 03.11.2015 16:26:16

&НаСервере
Процедура ОчиститьСписокВыбора()
    Дерево = РеквизитФормыВЗначение("СписокТемСИерархией", Тип("ДеревоЗначений"));
	Дерево.Строки.Очистить();
	ЗначениеВРеквизитФормы(Дерево, "СписокТемСИерархией");
КонецПроцедуры

&НаКлиенте
Процедура СписокТемСИерархиейВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	// { RGS Глебов Дмитрий 14.09.2016  - S-I-0001846, при выборе темы в отборе можно выбиреть группы 
	Если Элемент.ТекущиеДанные.ПоследнийЭлемент ИЛИ МожноВыбиратьГруппы Тогда 	
		Если ТипЗнч(ЭтаФорма.ВладелецФормы) = Тип("УправляемаяФорма") Тогда
			Закрыть();
			Оповестить("ОбработкаВыбора", Новый Структура("РезультатЗакрытия", Элемент.ТекущиеДанные.ТекстТемы), ЭтаФорма.ВладелецФормы);
		Иначе
			ОповеститьОВыборе(Элемент.ТекущиеДанные.ТекстТемы);
			
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры 

// } RGS Лунякин Иван 07.10.2015 13:53:54   