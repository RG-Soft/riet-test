
Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
		Поля.Добавить("Наименование");
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
	  	Представление = Данные.Наименование;
	КонецЕсли;
	 	       
КонецПроцедуры

