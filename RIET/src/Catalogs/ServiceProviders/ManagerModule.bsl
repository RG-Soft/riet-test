
//////////////////////////////////////////////////////////////////////
// СТАНДАРТНЫЕ ОБРАБОТЧИКИ

Процедура ОбработкаПолученияПолейПредставления(Поля, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
		Поля.Добавить("NameRus");
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПолученияПредставления(Данные, Представление, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() Тогда 
		СтандартнаяОбработка = Ложь;
	  	Представление = Данные.NameRus;
	КонецЕсли;
	 	       
КонецПроцедуры

Процедура ОбработкаПолученияДанныхВыбора(ДанныеВыбора, Параметры, СтандартнаяОбработка)
	
	Если РГСофтСерверПовтИспСеанс.ПолучитьПараметрСеансаShowNamesAndDescriptionsRUS() 
		И ЗначениеЗаполнено(Параметры.СтрокаПоиска) Тогда 
		
		СтандартнаяОбработка = Ложь;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("NameRus", Параметры.СтрокаПоиска + "%");
		
		Запрос.Текст = "ВЫБРАТЬ
		|	ServiceProviders.Ссылка
		|ИЗ
		|	Справочник.ServiceProviders КАК ServiceProviders
		|ГДЕ
		|	ServiceProviders.NameRus ПОДОБНО &NameRus
		|	И НЕ ServiceProviders.ПометкаУдаления";
		
		ТаблицаРезультатов = Запрос.Выполнить().Выгрузить();
		МассивСсылок = ТаблицаРезультатов.ВыгрузитьКолонку("Ссылка");
		ДанныеВыбора = Новый СписокЗначений;
		ДанныеВыбора.ЗагрузитьЗначения(МассивСсылок);
		
	КонецЕсли;
	
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////

Функция ПолучитьТаблицуServiceProviders() Экспорт
	
	// Возвращает таблицу складов, у которых заполнена дата Start of Int. inbound reports 
	        		
	Запрос = Новый Запрос;
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ServiceProviders.EMailBox КАК EMailBox,
			|	ServiceProviders.Ссылка КАК ServiceProvider,
			|	ServiceProviders.StartOfLeg7Reports КАК StartOfLeg7Reports,
			|	ServiceProviders.DefaultWarehouse КАК DefaultWarehouse,
			|	ServiceProviders.DefaultWarehouse.Код КАК DefaultWarehouseCode,
			|	ПланОбменаLeg7.Ссылка КАК УзелОбмена
			|ИЗ
			|	Справочник.ServiceProviders КАК ServiceProviders
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПланОбмена.Leg7 КАК ПланОбменаLeg7
			|		ПО ServiceProviders.Ссылка = ПланОбменаLeg7.ServiceProvider
			|ГДЕ
			|	ServiceProviders.StartOfLeg7Reports <> ДАТАВРЕМЯ(1, 1, 1)
			|	И НЕ ServiceProviders.ПометкаУдаления";
	Иначе
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ServiceProviders.EMailBoxTest КАК EMailBox,
			|	ServiceProviders.Ссылка КАК ServiceProvider,
			|	ServiceProviders.StartOfLeg7Reports КАК StartOfLeg7Reports,
			|	ServiceProviders.DefaultWarehouse КАК DefaultWarehouse,
			|	ServiceProviders.DefaultWarehouse.Код КАК DefaultWarehouseCode,
			|	ПланОбменаLeg7.Ссылка КАК УзелОбмена
			|ИЗ
			|	Справочник.ServiceProviders КАК ServiceProviders
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПланОбмена.Leg7 КАК ПланОбменаLeg7
			|		ПО ServiceProviders.Ссылка = ПланОбменаLeg7.ServiceProvider
			|ГДЕ
			|	ServiceProviders.StartOfLeg7Reports <> ДАТАВРЕМЯ(1, 1, 1)
			|	И НЕ ServiceProviders.ПометкаУдаления";
	КонецЕсли;
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция ПолучитьТаблицуServiceProvidersPOAs() Экспорт
	
	// Возвращает таблицу складов, у которых заполнена дата Start of Int. inbound reports 
	        		
	Запрос = Новый Запрос;
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ServiceProvidersPOAs.Ссылка.EMailBox,
			|	ServiceProvidersPOAs.Ссылка КАК ServiceProvider,
			|	ServiceProvidersPOAs.Ссылка.StartOfLeg7Reports КАК StartOfLeg7Reports,
			|	ServiceProvidersPOAs.POA,
			|	ServiceProvidersPOAs.Ссылка.DefaultWarehouse,
			|	ServiceProvidersPOAs.Ссылка.DefaultWarehouse.Код КАК DefaultWarehouseCode
			|ИЗ
			|	Справочник.ServiceProviders.POAs КАК ServiceProvidersPOAs
			|ГДЕ
			|	ServiceProvidersPOAs.Ссылка.StartOfLeg7Reports <> ДАТАВРЕМЯ(1, 1, 1)
			|	И НЕ ServiceProvidersPOAs.Ссылка.ПометкаУдаления";
	Иначе
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ServiceProvidersPOAs.Ссылка.EMailBoxTest КАК EMailBox,
			|	ServiceProvidersPOAs.Ссылка КАК ServiceProvider,
			|	ServiceProvidersPOAs.Ссылка.StartOfLeg7Reports КАК StartOfLeg7Reports,
			|	ServiceProvidersPOAs.POA,
			|	ServiceProvidersPOAs.Ссылка.DefaultWarehouse,
			|	ServiceProvidersPOAs.Ссылка.DefaultWarehouse.Код КАК DefaultWarehouseCode
			|ИЗ
			|	Справочник.ServiceProviders.POAs КАК ServiceProvidersPOAs
			|ГДЕ
			|	ServiceProvidersPOAs.Ссылка.StartOfLeg7Reports <> ДАТАВРЕМЯ(1, 1, 1)
			|	И НЕ ServiceProvidersPOAs.Ссылка.ПометкаУдаления";
	КонецЕсли;
		
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция WarehouseFromInLeg7(WarehouseFrom) Экспорт
	
	Если Не ЗначениеЗаполнено(WarehouseFrom) Тогда 
		Возврат Ложь;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Warehouse", WarehouseFrom);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ServiceProvidersWarehouses.Ссылка
		|ИЗ
		|	Справочник.ServiceProviders.Warehouses КАК ServiceProvidersWarehouses
		|ГДЕ
		|	НЕ ServiceProvidersWarehouses.Ссылка.ПометкаУдаления
		|	И ServiceProvidersWarehouses.Warehouse = &Warehouse
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	Warehouses.Ссылка
		|ИЗ
		|	Справочник.Warehouses КАК Warehouses
		|ГДЕ
		|	Warehouses.Port
		|	И НЕ Warehouses.ПометкаУдаления
		|	И Warehouses.Ссылка = &Warehouse";
		
	Результат = Запрос.Выполнить();
	Возврат Не Результат.Пустой(); 
			
КонецФункции

Функция ПолучитьEMailBoxForErrorMassagesПоОтправителю(АдресОтправителя) Экспорт
	
	EMailBoxForErrorMassages = "";
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("АдресОтправителя", АдресОтправителя);
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Запрос.Текст = "ВЫБРАТЬ
		|	ServiceProviders.EMailBoxForErrorMassages
		|ИЗ
		|	Справочник.ServiceProviders КАК ServiceProviders
		|ГДЕ
		|	НЕ ServiceProviders.ПометкаУдаления
		|	И ServiceProviders.EMailBoxInboxExchangeMessages = &АдресОтправителя";
	Иначе
		Запрос.Текст = "ВЫБРАТЬ
		|	ServiceProviders.EMailBoxForErrorMassagesTest КАК EMailBoxForErrorMassages
		|ИЗ
		|	Справочник.ServiceProviders КАК ServiceProviders
		|ГДЕ
		|	НЕ ServiceProviders.ПометкаУдаления
		|	И ServiceProviders.EMailBoxInboxExchangeMessagesTest = &АдресОтправителя";
	КонецЕсли;
	
	Выборка = запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		
		Возврат СокрЛП(Выборка.EMailBoxForErrorMassages);
		
	КонецЕсли;
	
	Возврат EMailBoxForErrorMassages;

КонецФункции

Функция ПолучитьServiceProviderПоОтправителю(АдресОтправителя) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("АдресОтправителя", АдресОтправителя);
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда
		Запрос.Текст = "ВЫБРАТЬ
		               |	ServiceProviders.Ссылка
		               |ИЗ
		               |	Справочник.ServiceProviders КАК ServiceProviders
		               |ГДЕ
		               |	НЕ ServiceProviders.ПометкаУдаления
		               |	И ServiceProviders.EMailBoxInboxExchangeMessages = &АдресОтправителя";
	Иначе
		Запрос.Текст = "ВЫБРАТЬ
		               |	ServiceProviders.Ссылка
		               |ИЗ
		               |	Справочник.ServiceProviders КАК ServiceProviders
		               |ГДЕ
		               |	НЕ ServiceProviders.ПометкаУдаления
		               |	И ServiceProviders.EMailBoxInboxExchangeMessagesTest = &АдресОтправителя";
	КонецЕсли;
	       		
	Выборка = запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		
		Возврат Выборка.Ссылка;
		
	КонецЕсли;
	
	Возврат Справочники.ServiceProviders.ПустаяСсылка();

КонецФункции

Функция ПолучитьМассивСобственныхСкладов(СервисПровайдер) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ServiceProvidersWarehouses.Warehouse
	|ПОМЕСТИТЬ ВТ_Склады
	|ИЗ
	|	Справочник.ServiceProviders.Warehouses КАК ServiceProvidersWarehouses
	|ГДЕ
	|	ServiceProvidersWarehouses.Ссылка = &ServiceProvider
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Склады.Warehouse
	|ИЗ
	|	ВТ_Склады КАК ВТ_Склады
	|ГДЕ
	|	НЕ ВТ_Склады.Warehouse В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					ServiceProvidersWarehouses.Warehouse
	|				ИЗ
	|					Справочник.ServiceProviders.Warehouses КАК ServiceProvidersWarehouses
	|				ГДЕ
	|					ServiceProvidersWarehouses.Ссылка <> &ServiceProvider)";
	
	Запрос.УстановитьПараметр("ServiceProvider", СервисПровайдер);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Warehouse");

КонецФункции // ()

Функция ПолучитьМассивСкладов(СервисПровайдер) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ServiceProvidersWarehouses.Warehouse
	|ИЗ
	|	Справочник.ServiceProviders.Warehouses КАК ServiceProvidersWarehouses
	|ГДЕ
	|	ServiceProvidersWarehouses.Ссылка = &ServiceProvider";
	
	Запрос.УстановитьПараметр("ServiceProvider", СервисПровайдер);
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Warehouse");	

КонецФункции // ()

