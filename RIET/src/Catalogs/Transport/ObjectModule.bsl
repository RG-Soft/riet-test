
//////////////////////////////////////////////////////////////////////
// ПРИ КОПИРОВАНИИ

Процедура ПриКопировании(ОбъектКопирования)
	
	РГСофт.ОчиститьCreationModification(ЭтотОбъект);
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////////////////////////////////
// ПЕРЕД ЗАПИСЬЮ

Процедура ПередЗаписью(Отказ)
	 
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ДозаполнитьРеквизиты();

	ПроверитьЗаполнениеРеквизитов(Отказ);
	      	
КонецПроцедуры
     
///////////////////////////////////////////////////////////////////////////////////////////////

Процедура ДозаполнитьРеквизиты()
	
	Если ЭтоНовый() Тогда
		РГСофт.ЗаполнитьCreation(ЭтотОбъект);
	КонецЕсли;

	Код = СокрЛП(Код);
	Brand = СокрЛП(Brand);
	Model = СокрЛП(Model);
	SemitrailerPN = СокрЛП(SemitrailerPN);
	SemitrailerBrand = СокрЛП(SemitrailerBrand);
	SemitrailerModel = СокрЛП(SemitrailerModel);
	
	Если Ссылка = Справочники.Transport.CallOut Тогда 
		Наименование = Код;
		TypeOfTransport = Перечисления.TypesOfTransport.CallOut;
	иначе
		Наименование = Brand + " " + Model + " " + Код;
	КонецЕсли;

	Если TypeOfTransport = Перечисления.TypesOfTransport.Own Тогда 
		ServiceProvider = Справочники.ServiceProviders.SLB;		
	КонецЕсли;
		
КонецПроцедуры

Процедура ПроверитьЗаполнениеРеквизитов(Отказ)
	
	Если ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(TypeOfTransport) Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
		"'Type of transport' is empty!",
		ЭтотОбъект, "TypeOfTransport", , Отказ);
		
	КонецЕсли;
	
	Если Ссылка <> Справочники.Transport.CallOut Тогда 
		
		Если НЕ ЗначениеЗаполнено(Equipment) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Equipment' is empty!",
			ЭтотОбъект, "Equipment", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Brand) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Brand' is empty!",
			ЭтотОбъект, "Brand", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Model) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Model' is empty!",
			ЭтотОбъект, "Model", , Отказ);
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Site) Тогда
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"'Site' is empty!",
			ЭтотОбъект, "Site", , Отказ);
		КонецЕсли;
		
		Если TypeOfTransport = Перечисления.TypesOfTransport.Rental Тогда
			
			Если НЕ ЗначениеЗаполнено(ServiceProvider) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Service provider' is empty!",
				ЭтотОбъект, "ServiceProvider", , Отказ);
			КонецЕсли; 
			
			Если НЕ ЗначениеЗаполнено(Geomarket) Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"'Geomarket' is empty!",
				ЭтотОбъект, "Geomarket", , Отказ);
			КонецЕсли; 
			
		КонецЕсли;
		
		Если TypeOfTransport = Перечисления.TypesOfTransport.Own 
			И ЗначениеЗаполнено(SemitrailerPN) Тогда
			
			Запрос = Новый Запрос;
			Запрос.Текст = "ВЫБРАТЬ
			|	Transport.Ссылка
			|ИЗ
			|	Справочник.Transport КАК Transport
			|ГДЕ
			|	Transport.SemitrailerPN = &SemitrailerPN
			|	И Transport.Ссылка <> &Ссылка";
			
			Запрос.УстановитьПараметр("Ссылка", Ссылка);
			Запрос.УстановитьПараметр("SemitrailerPN", SemitrailerPN);
			
			Выборка = Запрос.Выполнить().Выбрать();
			
			Если Выборка.Следующий() Тогда 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Semitrailer PN '" + SemitrailerPN  + "' is already used for " + СокрЛП(Выборка.Ссылка) + "!",
				ЭтотОбъект, "SemitrailerPN", , Отказ);
			КонецЕсли;
			
		КонецЕсли;

	КонецЕсли;
   			
КонецПроцедуры
