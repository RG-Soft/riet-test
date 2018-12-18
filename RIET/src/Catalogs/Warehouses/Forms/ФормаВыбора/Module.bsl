
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
		
	Отбор = Параметры.Отбор;	
    Отбор.Вставить("ПометкаУдаления", Ложь);
	
	// { RGS AFokin 24.09.2018 23:59:59 - S-I-0006036
	Если Параметры.Свойство("СписокДляОтбора") Тогда
		НастроитьСписокСОтбором(Параметры.СписокДляОтбора);
	КонецЕсли;	
	// } RGS AFokin 24.09.2018 23:59:59 - S-I-0006036
	
	// { RGS AFokin 21.10.2018 23:59:59 - S-I-0006152
	Если Параметры.Свойство("УсловиеДляОтбора") Тогда
		НастроитьСписокПоУсловию(Параметры.УсловиеДляОтбора);
	КонецЕсли;	
	// } RGS AFokin 21.10.2018 23:59:59 - S-I-0006152
	
КонецПроцедуры

// { RGS AFokin 24.09.2018 23:59:59 - S-I-0006036
&НаСервере
Процедура НастроитьСписокСОтбором(МассивНомеров)
	
	СписокКодовItems = Новый СписокЗначений;
	СписокКодовItems.ЗагрузитьЗначения(МассивНомеров);
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "RCACountry", СписокКодовItems, ВидСравненияКомпоновкиДанных.ВСписке,,Истина);
	
КонецПроцедуры
// } RGS AFokin 24.09.2018 23:59:59 - S-I-0006036

// { RGS AFokin  21.10.2018 23:59:59 - S-I-0006152
&НаСервере
Процедура НастроитьСписокПоУсловию(FacilityType)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбораДинамическогоСписка(Список, "FacilityType", FacilityType, ВидСравненияКомпоновкиДанных.Равно,,Истина);
	
КонецПроцедуры
// } RGS AFokin  21.10.2018 23:59:59 - S-I-0006152
