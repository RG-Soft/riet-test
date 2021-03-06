
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Отбор.Свойство("BatchOfCustomsFiles") Тогда
		
		Проведен = ОбщегоНазначения.ПолучитьЗначениеРеквизита(Параметры.Отбор.BatchOfCustomsFiles, "Проведен");
		Если НЕ Проведен Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"""" + Параметры.Отбор.BatchOfCustomsFiles + """ is not posted!",
				,,, Отказ);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеПользовательскихНастроекНаСервере(Настройки)
	
	// Если установлены дополнительные отборы - то пользовательские настройки надо снять
	Если Параметры.Свойство("Отбор") И Параметры.Отбор.Количество() Тогда	
		CustomsСервер.ОтменитьИспользованиеПараметровИОтборовВПользовательскихНастройках(Отчет.КомпоновщикНастроек.ПользовательскиеНастройки.Элементы);		
	КонецЕсли;
	
КонецПроцедуры