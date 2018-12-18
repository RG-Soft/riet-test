
Процедура PushCustomsFiles() Экспорт
	
	ТаблицаILC_ILM = РегистрыСведений.TCSInvoiceLinesClassification.ПолучитьТаблицуLastModifiedBefore(ТекущаяДата() - 3600);
	
	Для Каждого СтрокаILCиILM из ТаблицаILC_ILM Цикл 
		
		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Управляемый);
		
		Выборка = ПолучитьВыборкуCustomsFiles(СтрокаILCиILM.InvoiceLinesMatching, СтрокаILCиILM.ParentCompany);
		
		Определение = ПолучитьWSОпределениеПоParentCompany(СтрокаILCиILM.ParentCompany);
		
		Если Определение = Неопределено Тогда 
			ОтменитьТранзакцию();
			Продолжить;
		КонецЕсли;
		
		Data = Определение.ФабрикаXDTO.Создать(Определение.ФабрикаXDTO.Тип("http://www.riet.org","Data"));
		RowType = Определение.ФабрикаXDTO.Тип("http://www.riet.org", "row");
		
		Пока Выборка.Следующий() Цикл
			
			Row = Определение.ФабрикаXDTO.Создать(RowType);
			
			Row.CCD = СокрЛП(Выборка.CCD);
			Row.Date = Выборка.Date;
			Row.CustomsPost = СокрЛП(Выборка.CustomsPost);
			Row.CustomsPostName = СокрЛП(Выборка.CustomsPostName);
			Row.CustomsName = СокрЛП(Выборка.CustomsName);
			Row.CustomsLawsonCode = СокрЛП(Выборка.CustomsLawsonCode);
			Row.Borg = СокрЛП(Выборка.Borg);
			Row.PO = СокрЛП(Выборка.PO);
			Row.Invoice = СокрЛП(Выборка.Invoice);
			Row.InvoiceLine = СокрЛП(Выборка.InvoiceLine);
			Row.InvoiceCurrency = СокрЛП(Выборка.InvoiceCurrency);
			Row.InvoiceSeller = СокрЛП(Выборка.InvoiceSeller);
			Row.Part = СокрЛП(Выборка.Part);
			Row.Translation = СокрЛП(Выборка.Translation);
			Row.Qty = Выборка.Qty;
			Row.TotalPrice = Выборка.TotalPrice;
			Row.Freight = Выборка.Freight;
			Row.Handling = Выборка.Handling;
			Row.Insurance = Выборка.Insurance;
			Row.CCDfees = Выборка.CCDfees;
			Row.CCDduties = Выборка.CCDduties;
			Row.CCDVAT = Выборка.CCDVAT;
			// { RGS TChubarova 29.05.2015 15:35:19 - TCS-0002248
			Row.CountryOfOrigin 	= СокрЛП(Выборка.CountryOfOrigin);
			Row.CountryOfOriginName = СокрЛП(Выборка.CountryOfOriginName);
			// } RGS TChubarova 29.05.2015 15:35:38 - TCS-0002248
			Row.UOM = СокрЛП(Выборка.UOM);
			Row.BasicUomName = СокрЛП(Выборка.BasicUomName);
			Row.Type = СокрЛП(Выборка.Type);
			Row.TNVED = СокрЛП(Выборка.TNVED);
			
			Data.rows.Добавить(Row);
			
		КонецЦикла;
		
		Сервис = Новый WSПрокси(Определение, "http://www.riet.org", "rgsRIETDownload", "rgsRIETDownloadSoap");
		Сервис.Пользователь = "web";
		Сервис.Пароль = "4dm1n";
		
		Результат = Сервис.Download(Data);
		
		Если Результат Тогда 
			РегистрыСведений.TCSInvoiceLinesClassification.УдалитьЗапись(СтрокаILCиILM.InvoiceLinesClassification, СтрокаILCиILM.ParentCompany);
		КонецЕсли;	
		
		ЗафиксироватьТранзакцию();
		
	КонецЦикла;

КонецПроцедуры

Функция ПолучитьВыборкуCustomsFiles(InvoiceLinesMatching, ParentCompany)
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("InvoiceLinesMatching", InvoiceLinesMatching);
	Запрос.УстановитьПараметр("ParentCompany", ParentCompany);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВложенныйЗапрос.AU,
	               |	ВложенныйЗапрос.InvoiceLine КАК InvoiceLine,
	               |	СУММА(ВложенныйЗапрос.ИнвойсПеревозка) КАК ИнвойсПеревозка,
	               |	СУММА(ВложенныйЗапрос.ИнвойсХранение) КАК ИнвойсХранение,
	               |	СУММА(ВложенныйЗапрос.ИнвойсСтраховка) КАК ИнвойсСтраховка,
	               |	СУММА(ВложенныйЗапрос.ИнвойсСуммаСтрокиИнвойса) КАК ИнвойсСуммаСтрокиИнвойса,
	               |	СУММА(ВложенныйЗапрос.ПошлиныФискальные) КАК ПошлиныФискальные,
	               |	СУММА(ВложенныйЗапрос.СборыФискальные) КАК СборыФискальные,
	               |	СУММА(ВложенныйЗапрос.НДСФискальный) КАК НДСФискальный,
	               |	ВложенныйЗапрос.ParentCompany,
	               |	ВложенныйЗапрос.InvoiceLine.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ.Код КАК Borg,
	               |	ВложенныйЗапрос.ЗакрытиеПоставки
	               |ПОМЕСТИТЬ InvoiceLinesCostsОбороты
	               |ИЗ
	               |	(ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.AU КАК AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса КАК InvoiceLine,
	               |		InvoiceLinesCostsОбороты.СуммаОборот КАК ИнвойсПеревозка,
	               |		0 КАК ИнвойсХранение,
	               |		0 КАК ИнвойсСтраховка,
	               |		0 КАК ИнвойсСуммаСтрокиИнвойса,
	               |		0 КАК ПошлиныФискальные,
	               |		0 КАК СборыФискальные,
	               |		0 КАК НДСФискальный,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки) КАК ЗакрытиеПоставки
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсПеревозка)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo,
	               |		InvoiceLinesCostsОбороты.AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса,
	               |		0,
	               |		InvoiceLinesCostsОбороты.СуммаОборот,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки)
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсХранение)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo,
	               |		InvoiceLinesCostsОбороты.AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса,
	               |		0,
	               |		0,
	               |		InvoiceLinesCostsОбороты.СуммаОборот,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки)
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсСтраховка)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo,
	               |		InvoiceLinesCostsОбороты.AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса,
	               |		0,
	               |		0,
	               |		0,
	               |		InvoiceLinesCostsОбороты.СуммаОборот,
	               |		0,
	               |		0,
	               |		0,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки)
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ИнвойсСуммаСтрокиИнвойса)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo,
	               |		InvoiceLinesCostsОбороты.AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
	               |		0,
	               |		0,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки)
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняПошлины)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo,
	               |		InvoiceLinesCostsОбороты.AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
	               |		0,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки)
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняСборы)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}
	               |	
	               |	ОБЪЕДИНИТЬ ВСЕ
	               |	
	               |	ВЫБРАТЬ
	               |		InvoiceLinesCostsОбороты.SoldTo,
	               |		InvoiceLinesCostsОбороты.AU,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		0,
	               |		InvoiceLinesCostsОбороты.СуммаФискальнаяОборот,
	               |		ВЫРАЗИТЬ(InvoiceLinesCostsОбороты.Регистратор КАК Документ.ЗакрытиеПоставки)
	               |	ИЗ
	               |		РегистрНакопления.InvoiceLinesCosts.Обороты(, , Регистратор, ЭлементФормированияСтоимости = ЗНАЧЕНИЕ(Справочник.ЭлементыФормированияСтоимости.ТаможняНДС)) КАК InvoiceLinesCostsОбороты
	               |	ГДЕ
	               |		InvoiceLinesCostsОбороты.Регистратор = &InvoiceLinesMatching
	               |		И InvoiceLinesCostsОбороты.SoldTo = &ParentCompany
	               |	{ГДЕ
	               |		InvoiceLinesCostsОбороты.SoldTo.* КАК ParentCompany,
	               |		InvoiceLinesCostsОбороты.Segment.*,
	               |		InvoiceLinesCostsОбороты.AU.*,
	               |		InvoiceLinesCostsОбороты.ERPTreatment.*,
	               |		InvoiceLinesCostsОбороты.СтрокаИнвойса.* КАК InvoiceLine}) КАК ВложенныйЗапрос
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВложенныйЗапрос.InvoiceLine,
	               |	ВложенныйЗапрос.AU,
	               |	ВложенныйЗапрос.ParentCompany,
	               |	ВложенныйЗапрос.InvoiceLine.СтрокаЗаявкиНаЗакупку.Владелец.БОРГ.Код,
	               |	ВложенныйЗапрос.ЗакрытиеПоставки
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	InvoiceLine
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	InvoiceLinesCostsОбороты.ЗакрытиеПоставки,
	               |	InvoiceLinesCostsОбороты.InvoiceLine КАК InvoiceLine,
	               |	МАКСИМУМ(ЗакрытиеПоставкиСопоставление.ТоварСтрокиГТД.Владелец.КодТНВЭД) КАК TNVED
	               |ПОМЕСТИТЬ ВТ_Сопоставление
	               |ИЗ
	               |	Документ.ЗакрытиеПоставки.Сопоставление КАК ЗакрытиеПоставкиСопоставление
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ InvoiceLinesCostsОбороты КАК InvoiceLinesCostsОбороты
	               |		ПО ЗакрытиеПоставкиСопоставление.Ссылка = InvoiceLinesCostsОбороты.ЗакрытиеПоставки
	               |			И ЗакрытиеПоставкиСопоставление.СтрокаИнвойса = InvoiceLinesCostsОбороты.InvoiceLine
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	InvoiceLinesCostsОбороты.ЗакрытиеПоставки,
	               |	InvoiceLinesCostsОбороты.InvoiceLine
	               |
	               |ИНДЕКСИРОВАТЬ ПО
	               |	InvoiceLine
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ЕСТЬNULL(CustomsFilesOfGoods.CustomsFile.Номер, """") КАК CCD,
	               |	CustomsFilesOfGoods.CustomsFile.Дата КАК Date,
	               |	ЕСТЬNULL(CustomsFilesOfGoods.CustomsFile.CustomsPost.Код, """") КАК CustomsPost,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.СтрокаЗаявкиНаЗакупку.Владелец.Код, """") КАК PO,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.Инвойс.Номер, """") КАК Invoice,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.Наименование, """") КАК InvoiceLine,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.Инвойс.Валюта.Наименование, """") КАК InvoiceCurrency,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.Инвойс.Продавец.Наименование, """") КАК InvoiceSeller,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.КодПоИнвойсу, """") КАК Part,
	               |	ЕСТЬNULL(InvoiceLinesClassificationClassification.Translation, """") КАК Translation,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.Количество, 0) КАК Qty,
	               |	InvoiceLinesCostsОбороты.ИнвойсСуммаСтрокиИнвойса КАК TotalPrice,
	               |	InvoiceLinesCostsОбороты.ИнвойсПеревозка КАК Freight,
	               |	InvoiceLinesCostsОбороты.ИнвойсХранение КАК Handling,
	               |	InvoiceLinesCostsОбороты.ИнвойсСтраховка КАК Insurance,
	               |	InvoiceLinesCostsОбороты.СборыФискальные КАК CCDfees,
	               |	InvoiceLinesCostsОбороты.ПошлиныФискальные КАК CCDduties,
	               |	InvoiceLinesCostsОбороты.НДСФискальный КАК CCDVAT,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.ЕдиницаИзмерения.Код, """") КАК UOM,
	               |	ЕСТЬNULL(InvoiceLinesClassificationClassification.Type.Наименование, """") КАК Type,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.ParentCompany.Код, """") КАК ParentCompany,
	               |	InvoiceLinesCostsОбороты.Borg КАК Borg,
	               |	ЕСТЬNULL(InvoiceLinesCostsОбороты.InvoiceLine.ЕдиницаИзмерения.BasicUOM.Наименование, """") КАК BasicUomName,
	               |	ЕСТЬNULL(CustomsFilesOfGoods.CustomsFile.CustomsPost.Customs.LawsonContractor.Код, """") КАК CustomsLawsonCode,
	               |	ЕСТЬNULL(CustomsFilesOfGoods.CustomsFile.CustomsPost.Наименование, """") КАК CustomsPostName,
	               |	ЕСТЬNULL(CustomsFilesOfGoods.CustomsFile.CustomsPost.Customs.Наименование, """") КАК CustomsName,
	               |	ЕСТЬNULL(ВТ_Сопоставление.TNVED, """") КАК TNVED
	               |ИЗ
	               |	InvoiceLinesCostsОбороты КАК InvoiceLinesCostsОбороты
	               |		{ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.CustomsFilesOfGoods КАК CustomsFilesOfGoods
	               |		ПО InvoiceLinesCostsОбороты.InvoiceLine = CustomsFilesOfGoods.Item}
	               |		{ЛЕВОЕ СОЕДИНЕНИЕ Документ.InvoiceLinesClassification.Classification КАК InvoiceLinesClassificationClassification
	               |		ПО InvoiceLinesCostsОбороты.InvoiceLine = InvoiceLinesClassificationClassification.InvoiceLine}
	               |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Сопоставление КАК ВТ_Сопоставление
	               |		ПО InvoiceLinesCostsОбороты.ЗакрытиеПоставки = ВТ_Сопоставление.ЗакрытиеПоставки
	               |			И InvoiceLinesCostsОбороты.InvoiceLine = ВТ_Сопоставление.InvoiceLine";
	// { RGS TChubarova 29.05.2015 15:35:19 - TCS-0002248
	Запрос.Текст = СтрЗаменить(Запрос.Текст, "InvoiceLinesCostsОбороты.НДСФискальный КАК CCDVAT,", "InvoiceLinesCostsОбороты.НДСФискальный КАК CCDVAT,
	               |	InvoiceLinesCostsОбороты.InvoiceLine.СтранаПроисхождения.Код КАК CountryOfOrigin,
				   |	ВЫБОР
				   | 	 	КОГДА ТИПЗНАЧЕНИЯ(InvoiceLinesCostsОбороты.InvoiceLine.СтранаПроисхождения) = ТИП(СТРОКА)
				   |			ТОГДА InvoiceLinesCostsОбороты.InvoiceLine.СтранаПроисхождения
				   |	 	ИНАЧЕ InvoiceLinesCostsОбороты.InvoiceLine.СтранаПроисхождения.Наименование
				   | 	КОНЕЦ КАК CountryOfOriginName,"); 
	// } RGS TChubarova 29.05.2015 15:35:38 - TCS-0002248
	
	Возврат Запрос.Выполнить().Выбрать();
		
КонецФункции

Функция ПолучитьWSОпределениеПоParentCompany(ParentCompany)
	
	Если РГСофтСерверПовтИспСеанс.ЭтоProductionБаза() Тогда 
		
		Если ParentCompany = ImportExportСерверПовтИспСеанс.ПолучитьParentCompanyПоКоду("TCS") Тогда 
			Возврат Новый WSОпределения("http://ru0021app04.dir.slb.com/ws_tcs_riet_work/ws/wsRIETDownload.1cws?wsdl", "web", "4dm1n");
		ИначеЕсли ParentCompany = ImportExportСерверПовтИспСеанс.ПолучитьParentCompanyПоКоду("SLB Vostok") Тогда 
			Возврат Новый WSОпределения("http://ru0021app04.dir.slb.com/ws_svs_riet_work/ws/wsRIETDownload.1cws?wsdl", "web", "4dm1n");
		ИначеЕсли ParentCompany = ImportExportСерверПовтИспСеанс.ПолучитьParentCompanyПоКоду("OPS") Тогда 
			Возврат Новый WSОпределения("http://ru0021app04.dir.slb.com/ws_ops_riet_work/ws/wsRIETDownload.1cws?wsdl", "web", "4dm1n");
		иначе
			Возврат Неопределено;
		КонецЕсли;
		
	иначе
		
		Если ParentCompany = ImportExportСерверПовтИспСеанс.ПолучитьParentCompanyПоКоду("TCS") Тогда 
			Возврат Новый WSОпределения("http://ru0021app04.dir.slb.com/ws_svs_riet_test/ws/wsRIETDownload.1cws?wsdl", "web", "4dm1n");
		ИначеЕсли ParentCompany = ImportExportСерверПовтИспСеанс.ПолучитьParentCompanyПоКоду("SLB Vostok") Тогда 
			Возврат Новый WSОпределения("http://ru0021app04.dir.slb.com/ws_svs_riet_test/ws/wsRIETDownload.1cws?wsdl", "web", "4dm1n");
		иначе
			Возврат Неопределено;
		КонецЕсли;	
		
	КонецЕсли;
	
КонецФункции
