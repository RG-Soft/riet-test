
// ПЕРЕНЕСТИ В МОДУЛЬ МЕНЕДЖЕРА СПРАВОЧНИКА СтрокиИнвойса
Функция ПолучитьТаблицуInvoiceLines(Invoice) Экспорт
	
	Запрос = Новый Запрос();
	Запрос.УстановитьПараметр("Ссылка", Invoice);
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Items.Ссылка,
		|	Items.Наименование,
		|	Items.НомерСтрокиИнвойса,
		|	Items.СтрокаЗаявкиНаЗакупку,
		|	Items.КодПоИнвойсу,
		|	Items.Каталог,
		|	Items.НаименованиеТовара,
		|	Items.Количество,
		|	Items.ЕдиницаИзмерения,
		|	Items.Цена,
		|	Items.Сумма,
		|	Items.ImportReference,
		|	Items.КостЦентр,
		|	Items.Классификатор,
		|	Items.Активити,
		|	Items.СтранаПроисхождения,
		|	Items.МеждународныйКодТНВЭД,
		|	Items.СерийныйНомер,
		|	Items.НомерВходящейДекларации,
		|	Items.Инвойс,
		|	Items.НомерЗаявкиНаЗакупку,
		|	Items.SoldTo,
		|	Items.Currency,
		|	Items.Manufacturer,
		|	Items.NetWeight,
		|	Items.WeightUOM,
		|	Items.PermanentTemporary,
		|	Items.PSA,
		|	Items.PermitsRequired,
		|	Items.Final,
		|	Items.EUCNotRequired,
		|	Items.EUCRequested,
		|	Items.EUCReceived,
		|	Items.SCNo,
		|	Items.TNVED,
		|	Items.COORequired,
		|	Items.ClientPO КАК ClientPO,
		// { RGS AGorlenko 30.05.2017 14:55:41 - иначе не сопоставляются данные со строками инвойса
		//|	Items.ClientPO.ClientPONo КАК ClientPONo,
		//|	Items.ClientPO.ClientLineNo КАК ClientLineNo,
		//|	Items.ClientPO.ClientPartNo КАК ClientPartNo,
		//|	Items.ClientPO.ClientDescription КАК ClientDescription,
		//|	Items.ClientPO.ClientQty КАК ClientQty,
		//|	Items.ClientPO.InitialCost КАК InitialCost,
		//|	Items.ClientPO.InitialTotalPrice КАК InitialTotalPrice,
		//|	Items.ClientPO.ClientQtyUOM КАК ClientQtyUOM,
		|	ЕСТЬNULL(Items.ClientPO.ClientPONo, """") КАК ClientPONo,
		|	ЕСТЬNULL(Items.ClientPO.ClientLineNo, 0) КАК ClientLineNo,
		|	ЕСТЬNULL(Items.ClientPO.ClientPartNo, """") КАК ClientPartNo,
		|	ЕСТЬNULL(Items.ClientPO.ClientDescription, """") КАК ClientDescription,
		|	ЕСТЬNULL(Items.ClientPO.ClientQty, 0) КАК ClientQty,
		|	ЕСТЬNULL(Items.ClientPO.InitialCost, 0) КАК InitialCost,
		|	ЕСТЬNULL(Items.ClientPO.InitialTotalPrice, 0) КАК InitialTotalPrice,
		|	ЕСТЬNULL(Items.ClientPO.ClientQtyUOM, ЗНАЧЕНИЕ(Справочник.UOMs.ПустаяСсылка)) КАК ClientQtyUOM,
		// } RGS AGorlenko 30.05.2017 14:56:09 - иначе не сопоставляются данные со строками инвойса
		|	Items.ProjectMobilization
		|ИЗ
		|	Справочник.СтрокиИнвойса КАК Items
		|ГДЕ
		|	Items.Инвойс.Ссылка = &Ссылка
		|	И НЕ Items.ПометкаУдаления
		|
		|УПОРЯДОЧИТЬ ПО
		|	Items.НомерСтрокиИнвойса";
				   
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

// { RGS DKazanskiy 20.12.2018 13:52:25 - S-I-0006324
Процедура ОбновитьФлагEUCNotRequired(Инвойс) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	СтрокиИнвойса.Ссылка
	|ИЗ
	|	Справочник.СтрокиИнвойса КАК СтрокиИнвойса
	|ГДЕ
	|	СтрокиИнвойса.EUCNotRequired
	|	И СтрокиИнвойса.Инвойс = &Инвойс
	|	И СтрокиИнвойса.СтранаПроисхождения.Код = ""US""";
	
	Запрос.УстановитьПараметр("Инвойс", Инвойс);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		
		НачатьТранзакцию();
		
		Объект = Результат.ссылка.ПолучитьОбъект();
		Объект.Заблокировать();
		Объект.ОбменДанными.Загрузка = Истина;
		
		Объект.EUCNotRequired = Ложь;
		
		Попытка 
			Объект.Записать();
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры
// } RGS DKazanskiy 20.12.2018 13:52:33 - S-I-0006324