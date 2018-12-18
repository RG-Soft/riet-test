
Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
		
	ДозаполнитьРеквизитыБезДополнительныхДанных();
	
	ПроверитьЗаполнениеРеквизитов(Отказ);
		
КонецПроцедуры

Процедура ДозаполнитьРеквизитыБезДополнительныхДанных()
	
	Наименование = СокрЛП(Наименование);
	Address1 = СокрЛП(Address1);
	NameForMoveIt = СокрЛП(NameForMoveIt);
	CompanyNo = СокрЛП(CompanyNo);
	NameRus = СокрЛП(NameRus);
	PostalAddressForInvoiceAndSupportingDocuments = СокрЛП(PostalAddressForInvoiceAndSupportingDocuments);
	PostalAddressForInvoiceAndSupportingDocumentsRus = СокрЛП(PostalAddressForInvoiceAndSupportingDocumentsRus);
	
	Если НЕ ЗначениеЗаполнено(ParentCompanyForPayments) Тогда
		
		Если ЭтоНовый() Тогда
			УстановитьСсылкуНового(Справочники.SoldTo.ПолучитьСсылку());
			ParentCompanyForPayments = ПолучитьСсылкуНового();
		Иначе
			ParentCompanyForPayments = Ссылка;
		КонецЕсли;
				
	КонецЕсли;
	
КонецПроцедуры 

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СокрЛП(Код)) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Code' is empty!",
			ЭтотОбъект, "Код", , Отказ);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Наименование) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Name' is empty!",
			ЭтотОбъект, "Наименование", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Country) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Country' is empty!",
			ЭтотОбъект, "Country", , Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Address1) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Address 1' is empty!",
			ЭтотОбъект, "Address1", , Отказ);
	КонецЕсли; 
	
	Если НЕ ЗначениеЗаполнено(ParentCompanyForPayments) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Parent co. for payments' is empty!",
			ЭтотОбъект, "ParentCompanyForPayments", , Отказ);	
	КонецЕсли;
	
	Если Lawson Тогда
		
		Если НЕ ЗначениеЗаполнено(CompanyNo) Тогда	
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Company no.' is empty!",
				ЭтотОбъект, "CompanyNo", , Отказ);	
		КонецЕсли;
		
	КонецЕсли;
	
	Если Leg7LegalEntityDetermining = Перечисления.Leg7LegalEntityDetermining.DefaultLegalEntity
		И Не ЗначениеЗаполнено(LegalEntityForLeg7) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Default Legal entity' is empty!",
			ЭтотОбъект, "LegalEntityForLeg7", , Отказ);
	КонецЕсли;
	
КонецПроцедуры
