
Функция ПолучитьДоступныеItemsДляCustomsFileИCustomsBond(TypeOfTransaction, Shipment, ParentCompany, PermanentTemporary, PSAContract, CurrentCustomsFileLight) Экспорт
	
	// возвращает массив items, доступных для типов операции Customs file и Customs bond
	
	Если НЕ ЗначениеЗаполнено(TypeOfTransaction) Тогда
		ВызватьИсключение "Type of transaction is empty!";
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Shipment) Тогда
		ВызватьИсключение "Shipment is empty!";
	КонецЕсли;
	
	Запрос = Новый Запрос;
			
	Запрос.УстановитьПараметр("TypeOfTransaction", TypeOfTransaction);
	Запрос.УстановитьПараметр("Shipment", Shipment);
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	Запрос.УстановитьПараметр("PermanentTemporary", PermanentTemporary);
	Запрос.УстановитьПараметр("PSAContract", PSAContract);
	Запрос.УстановитьПараметр("CurrentCustomsFileLight", CurrentCustomsFileLight);
	
	ТипЗначенияShipment = ТипЗнч(Shipment);
	Если ТипЗначенияShipment = Тип("ДокументСсылка.Поставка") Тогда
		
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	Items.Ссылка
			|ИЗ
			|	Документ.Поставка.УпаковочныеЛисты КАК ImportShipmentDOCs
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Инвойсы КАК DOCsInvoices
			|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
			|				ЛЕВОЕ СОЕДИНЕНИЕ Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
			|				ПО Items.Ссылка = CustomsFilesLightItems.Item
			|					И (CustomsFilesLightItems.Ссылка.TypeOfTransaction = &TypeOfTransaction)
			|					И (CustomsFilesLightItems.Ссылка.Shipment = &Shipment)
			|					И (НЕ CustomsFilesLightItems.Ссылка.ПометкаУдаления)
			|					И (CustomsFilesLightItems.Ссылка <> &CurrentCustomsFileLight)
			|			ПО DOCsInvoices.Инвойс = Items.Инвойс
			|				И (НЕ Items.ПометкаУдаления)
			|		ПО ImportShipmentDOCs.УпаковочныйЛист = DOCsInvoices.Ссылка
			|ГДЕ
			|	ImportShipmentDOCs.Ссылка = &Shipment
			|	И ВЫБОР
			|			КОГДА &ParentCompany = ЗНАЧЕНИЕ(Справочник.SoldTo.ПустаяСсылка)
			|				ТОГДА ИСТИНА
			|			ИНАЧЕ Items.SoldTo = &ParentCompany
			|		КОНЕЦ
			|	И ВЫБОР
			|			КОГДА &PermanentTemporary = ЗНАЧЕНИЕ(Перечисление.PermanentTemporary.ПустаяСсылка)
			|				ТОГДА ИСТИНА
			|			ИНАЧЕ Items.PermanentTemporary = &PermanentTemporary
			|		КОНЕЦ
			|	И ВЫБОР
			|			КОГДА &PSAContract = ЗНАЧЕНИЕ(Справочник.PSAContracts.ПустаяСсылка)
			|				ТОГДА ИСТИНА
			|			ИНАЧЕ Items.PSA = &PSAContract
			|		КОНЕЦ
			|	И CustomsFilesLightItems.Item ЕСТЬ NULL ";
		
	ИначеЕсли ТипЗначенияShipment = Тип("ДокументСсылка.ExportShipment") Тогда
		
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	Items.Ссылка
			|ИЗ
			|	Документ.ExportShipment.ExportRequests КАК ExportShipmentExportRequests
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.СтрокиИнвойса КАК Items
			|			ЛЕВОЕ СОЕДИНЕНИЕ Документ.CustomsFilesLight.Items КАК CustomsFilesLightItems
			|			ПО Items.Ссылка = CustomsFilesLightItems.Item
			|				И (CustomsFilesLightItems.Ссылка.Shipment = &Shipment)
			|				И (CustomsFilesLightItems.Ссылка.TypeOfTransaction = &TypeOfTransaction)
			|				И (НЕ CustomsFilesLightItems.Ссылка.ПометкаУдаления)
			|				И (CustomsFilesLightItems.Ссылка <> &CurrentCustomsFileLight)
			|		ПО ExportShipmentExportRequests.ExportRequest = Items.ExportRequest
			|			И (НЕ Items.ПометкаУдаления)
			|ГДЕ
			|	ExportShipmentExportRequests.Ссылка = &Shipment
			|	И ВЫБОР
			|			КОГДА &ParentCompany = ЗНАЧЕНИЕ(Справочник.SoldTo.ПустаяСсылка)
			|				ТОГДА ИСТИНА
			|			ИНАЧЕ Items.SoldTo = &ParentCompany
			|		КОНЕЦ
			|	И ВЫБОР
			|			КОГДА &PermanentTemporary = ЗНАЧЕНИЕ(Перечисление.PermanentTemporary.ПустаяСсылка)
			|				ТОГДА ИСТИНА
			|			ИНАЧЕ Items.PermanentTemporary = &PermanentTemporary
			|		КОНЕЦ
			|	И ВЫБОР
			|			КОГДА &PSAContract = ЗНАЧЕНИЕ(Справочник.PSAContracts.ПустаяСсылка)
			|				ТОГДА ИСТИНА
			|			ИНАЧЕ Items.PSA = &PSAContract
			|		КОНЕЦ
			|	И CustomsFilesLightItems.Item ЕСТЬ NULL ";
			
	Иначе
		ВызватьИсключение "Unknown shipment type '" + ТипЗначенияShipment + "'!";
	КонецЕсли;
	
	Возврат Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
				
КонецФункции

Функция ПолучитьРеквизитыItems(Items, ImportExport) Экспорт
	
	// для переданного массива Items, возвращает таблицу реквизитов, необходимую для работы документа Customs files light
	
	Если НЕ ЗначениеЗаполнено(ImportExport) Тогда
		ВызватьИсключение "Imp. / exp. is empty!";	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	
	Запрос.УстановитьПараметр("Items", Items);
	
	Если ImportExport = Перечисления.ИмпортЭкспорт.Import Тогда
		
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ParcelsItems.СтрокаИнвойса КАК Item,
			|	DOCsParcels.Ссылка.Номер КАК DOCNo,
			|	ParcelsItems.СтрокаИнвойса.Инвойс.Номер КАК ImportInvoiceNoExportRequestNo,
			|	ParcelsItems.СтрокаИнвойса.НомерСтрокиИнвойса КАК LineNo,
			|	ParcelsItems.СтрокаИнвойса.НомерЗаявкиНаЗакупку КАК PONo,
			|	ParcelsItems.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
			|	ParcelsItems.СтрокаИнвойса.СерийныйНомер КАК SerialNo,
			|	ВЫРАЗИТЬ(ParcelsItems.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(1024)) КАК Description,
			|	ParcelsItems.СтрокаИнвойса.Количество КАК Qty,
			|	ParcelsItems.СтрокаИнвойса.ЕдиницаИзмерения.Код КАК QtyUOMCode,
			|	СУММА(ParcelsItems.NetWeight) КАК ParcelsNetWeight,
			|	ParcelsItems.Ссылка.WeightUOM.Код КАК WeightUOMCode,
			|	ParcelsItems.СтрокаИнвойса.СтранаПроисхождения КАК CountryOfOrigin,
			|	ParcelsItems.СтрокаИнвойса.МеждународныйКодТНВЭД КАК InvoiceHTC,
			|	ParcelsItems.СтрокаИнвойса.Цена КАК Price,
			|	ParcelsItems.СтрокаИнвойса.Currency КАК Currency,
			|	ParcelsItems.СтрокаИнвойса.Currency.НаименованиеEng КАК CurrencyNameEng,
			|	ParcelsItems.СтрокаИнвойса.Сумма КАК TotalPrice,
			|	ParcelsItems.СтрокаИнвойса.SoldTo КАК ParentCompany,
			|	ParcelsItems.СтрокаИнвойса.PermanentTemporary КАК PermanentTemporary,
			|	ParcelsItems.СтрокаИнвойса.PSA КАК PSAContract,
			|	ParcelsItems.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку КАК POLine,
			|	ParcelsItems.СтрокаИнвойса.КостЦентр КАК AU
			|ИЗ
			|	Справочник.Parcels.Детали КАК ParcelsItems
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.КонсолидированныйПакетЗаявокНаПеревозку.Parcels КАК DOCsParcels
			|		ПО ParcelsItems.Ссылка = DOCsParcels.Parcel
			|			И (НЕ DOCsParcels.Ссылка.Отменен)
			|ГДЕ
			|	ParcelsItems.СтрокаИнвойса В(&Items)
			|
			|СГРУППИРОВАТЬ ПО
			|	DOCsParcels.Ссылка.Номер,
			|	ParcelsItems.СтрокаИнвойса,
			|	ParcelsItems.СтрокаИнвойса.Инвойс.Номер,
			|	ParcelsItems.СтрокаИнвойса.НомерСтрокиИнвойса,
			|	ParcelsItems.СтрокаИнвойса.НомерЗаявкиНаЗакупку,
			|	ParcelsItems.СтрокаИнвойса.КодПоИнвойсу,
			|	ParcelsItems.СтрокаИнвойса.СерийныйНомер,
			|	ВЫРАЗИТЬ(ParcelsItems.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(1024)),
			|	ParcelsItems.СтрокаИнвойса.Количество,
			|	ParcelsItems.СтрокаИнвойса.ЕдиницаИзмерения.Код,
			|	ParcelsItems.Ссылка.WeightUOM.Код,
			|	ParcelsItems.СтрокаИнвойса.СтранаПроисхождения,
			|	ParcelsItems.СтрокаИнвойса.МеждународныйКодТНВЭД,
			|	ParcelsItems.СтрокаИнвойса.Цена,
			|	ParcelsItems.СтрокаИнвойса.Currency,
			|	ParcelsItems.СтрокаИнвойса.Currency.НаименованиеEng,
			|	ParcelsItems.СтрокаИнвойса.Сумма,
			|	ParcelsItems.СтрокаИнвойса.SoldTo,
			|	ParcelsItems.СтрокаИнвойса.PermanentTemporary,
			|	ParcelsItems.СтрокаИнвойса.PSA,
			|	ParcelsItems.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку,
			|	ParcelsItems.СтрокаИнвойса.КостЦентр
			|
			|УПОРЯДОЧИТЬ ПО
			|	DOCNo,
			|	ImportInvoiceNoExportRequestNo,
			|	LineNo";
		
	ИначеЕсли ImportExport = Перечисления.ИмпортЭкспорт.Export Тогда
		
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ParcelsItems.СтрокаИнвойса КАК Item,
			|	ParcelsItems.Ссылка.ExportRequest.Номер КАК ImportInvoiceNoExportRequestNo,
			|	ParcelsItems.СтрокаИнвойса.НомерСтрокиИнвойса КАК LineNo,
			|	ParcelsItems.СтрокаИнвойса.НомерЗаявкиНаЗакупку КАК PONo,
			|	ParcelsItems.СтрокаИнвойса.КодПоИнвойсу КАК PartNo,
			|	ParcelsItems.СтрокаИнвойса.СерийныйНомер КАК SerialNo,
			|	ВЫРАЗИТЬ(ParcelsItems.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(1024)) КАК Description,
			|	ParcelsItems.СтрокаИнвойса.Количество КАК Qty,
			|	ParcelsItems.СтрокаИнвойса.ЕдиницаИзмерения.Код КАК QtyUOMCode,
			|	СУММА(ParcelsItems.NetWeight) КАК ParcelsNetWeight,
			|	ParcelsItems.Ссылка.WeightUOM.Код КАК WeightUOMCode,
			|	ParcelsItems.СтрокаИнвойса.СтранаПроисхождения КАК CountryOfOrigin,
			|	ParcelsItems.СтрокаИнвойса.МеждународныйКодТНВЭД КАК InvoiceHTC,
			|	ParcelsItems.СтрокаИнвойса.Цена КАК Price,
			|	ParcelsItems.СтрокаИнвойса.Currency КАК Currency,
			|	ParcelsItems.СтрокаИнвойса.Currency.НаименованиеEng КАК CurrencyNameEng,
			|	ParcelsItems.СтрокаИнвойса.Сумма КАК TotalPrice,
			|	ParcelsItems.СтрокаИнвойса.SoldTo КАК ParentCompany,
			|	ParcelsItems.СтрокаИнвойса.PermanentTemporary КАК PermanentTemporary,
			|	ParcelsItems.СтрокаИнвойса.PSA КАК PSAContract,
			|	ParcelsItems.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку КАК POLine,
			|	ParcelsItems.СтрокаИнвойса.КостЦентр КАК AU
			|ИЗ
			|	Справочник.Parcels.Детали КАК ParcelsItems
			|ГДЕ
			|	ParcelsItems.СтрокаИнвойса В(&Items)
			|	И НЕ ParcelsItems.Ссылка.Отменен
			|
			|СГРУППИРОВАТЬ ПО
			|	ParcelsItems.СтрокаИнвойса,
			|	ParcelsItems.Ссылка.ExportRequest.Номер,
			|	ParcelsItems.СтрокаИнвойса.НомерСтрокиИнвойса,
			|	ParcelsItems.СтрокаИнвойса.КодПоИнвойсу,
			|	ParcelsItems.СтрокаИнвойса.СерийныйНомер,
			|	ParcelsItems.СтрокаИнвойса.Количество,
			|	ParcelsItems.СтрокаИнвойса.ЕдиницаИзмерения.Код,
			|	ParcelsItems.Ссылка.WeightUOM.Код,
			|	ParcelsItems.СтрокаИнвойса.СтранаПроисхождения,
			|	ParcelsItems.СтрокаИнвойса.МеждународныйКодТНВЭД,
			|	ParcelsItems.СтрокаИнвойса.Цена,
			|	ParcelsItems.СтрокаИнвойса.Currency,
			|	ParcelsItems.СтрокаИнвойса.Currency.НаименованиеEng,
			|	ParcelsItems.СтрокаИнвойса.Сумма,
			|	ВЫРАЗИТЬ(ParcelsItems.СтрокаИнвойса.НаименованиеТовара КАК СТРОКА(1024)),
			|	ParcelsItems.СтрокаИнвойса.SoldTo,
			|	ParcelsItems.СтрокаИнвойса.PermanentTemporary,
			|	ParcelsItems.СтрокаИнвойса.PSA,
			|	ParcelsItems.СтрокаИнвойса.НомерЗаявкиНаЗакупку,
			|	ParcelsItems.СтрокаИнвойса.СтрокаЗаявкиНаЗакупку,
			|	ParcelsItems.СтрокаИнвойса.КостЦентр
			|
			|УПОРЯДОЧИТЬ ПО
			|	ImportInvoiceNoExportRequestNo,
			|	LineNo";
		
	КонецЕсли;
	
	ТаблицаItems = Запрос.Выполнить().Выгрузить();
	ТаблицаItems.Индексы.Добавить("Item");
	Возврат ТаблицаItems;
	
КонецФункции

Функция ПолучитьCustomsDepositSum(CustomsFile, ДокументСсылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Дата", ТекущаяДатаСеанса());
	Запрос.УстановитьПараметр("CustomsFilesLight", CustomsFile);
	Запрос.УстановитьПараметр("Регистратор", ДокументСсылка);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	СУММА(ЕСТЬNULL(CustomsDepositsОбороты.SumОборот, 0)) КАК Сумма
	               |ИЗ
	               |	РегистрНакопления.CustomsDeposits.Обороты(, , Регистратор, Cu = &CustomsFilesLight) КАК CustomsDepositsОбороты
	               |ГДЕ
	               |	CustomsDepositsОбороты.Регистратор <> &Регистратор";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Следующий() Тогда 
		Возврат Выборка.Сумма;
	КонецЕсли;
	
	Возврат 0;	
	
КонецФункции
