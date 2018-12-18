
Процедура ПередЗаписью(Отказ)
	
	Наименование = СокрЛП(Наименование);
	ItemDescription = СокрЛП(ItemDescription);
	DescriptionRus = СокрЛП(DescriptionRus);
	
	Если DomesticInternational = Перечисления.DomesticInternational.International Тогда 
		ReadyToShip = Неопределено;
		PickUpWarehouse = Неопределено;
		DeliverTo = Неопределено;
	ИначеЕсли DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда 
		SupplierAvailability = Неопределено;
		POD = Неопределено;
		Supplier = Неопределено;
	КонецЕсли;
	
	ПроверитьЗаполнениеРеквизитов(Отказ)

КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	Если ЗначениеЗаполнено(Item) Тогда 
		ItemОбъект = Item.ПолучитьОбъект(); 
		ItemОбъект.ProjectMobilization = Владелец;			
		ItemОбъект.ОбменДанными.Загрузка = Истина;
		ItemОбъект.Записать();
	КонецЕсли;
	
	Если ЗначениеЗаполнено(POLine) Тогда 
		POLineОбъект = POLine.ПолучитьОбъект(); 
		POLineОбъект.ProjectMobilization = Владелец;			
		POLineОбъект.ОбменДанными.Загрузка = Истина;
		POLineОбъект.Записать();
	КонецЕсли;

КонецПроцедуры

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	        	
	Если DomesticInternational = Перечисления.DomesticInternational.International Тогда 
		
		Если НЕ ЗначениеЗаполнено(SupplierAvailability) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Supplier availability date' is empty!",
			ЭтотОбъект, "SupplierAvailability", , Отказ);
		КонецЕсли;
		
	ИначеЕсли DomesticInternational = Перечисления.DomesticInternational.Domestic Тогда 
		
		Если НЕ ЗначениеЗаполнено(ReadyToShip) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Ready to ship date' is empty!",
			ЭтотОбъект, "ReadyToShip", , Отказ);
		КонецЕсли;
		
	КонецЕсли;
   			
КонецПроцедуры
