
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	НастроитьManualItems();
	
КонецПроцедуры

&НаКлиенте
Процедура НастроитьManualItems()
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		ManualItems.Отбор,
		"ProjectMobilization",
		?(ЗначениеЗаполнено(Объект.Ссылка), Объект.Ссылка, Неопределено),
		ВидСравненияКомпоновкиДанных.Равно,
		,
		Истина);
		
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	РГСофт.ЗаполнитьModification(ТекущийОбъект);

КонецПроцедуры
