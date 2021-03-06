Процедура СформироватьЗаписиМестонахождениеОС() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.Организация,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.МОЛ,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.Местонахождение,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.КостЦентр
	|ИЗ
	|	РегистрСведений.МестонахождениеОСБухгалтерскийУчет.СрезПоследних(&Дата, ) КАК МестонахождениеОСБухгалтерскийУчетСрезПоследних
	|ГДЕ
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.КостЦентр = &КостЦентр";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("КостЦентр", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяЗапись = Движения.МестонахождениеОСБухгалтерскийУчет.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяЗапись, Выборка);
		НоваяЗапись.Период = Дата;
		НоваяЗапись.КостЦентр = AU;
	КонецЦикла;		
	
КонецПроцедуры

Процедура СформироватьДвиженияВзаиморасчетыСПокупателями() Экспорт
	
	Набор = Движения.ВзаиморасчетыСПокупателями;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ВзаиморасчетыСПокупателямиОстатки.ДоговорКонтрагента,
	|	ВзаиморасчетыСПокупателямиОстатки.ПодразделениеОрганизации,
	|	ВзаиморасчетыСПокупателямиОстатки.Сделка,
	|	ВзаиморасчетыСПокупателямиОстатки.СчетНаПредоплату,
	|	ВзаиморасчетыСПокупателямиОстатки.КостЦентр,
	|	ВзаиморасчетыСПокупателямиОстатки.ИнвойсинговыйЦентр,
	|	ВзаиморасчетыСПокупателямиОстатки.WO,
	|	ВзаиморасчетыСПокупателямиОстатки.СуммаВзаиморасчетовОстаток КАК СуммаВзаиморасчетов,
	|	ВзаиморасчетыСПокупателямиОстатки.СуммаУпрОстаток КАК СуммаУпр,
	|	ВзаиморасчетыСПокупателямиОстатки.СуммаРеглОстаток КАК СуммаРегл
	|ИЗ
	|	РегистрНакопления.ВзаиморасчетыСПокупателями.Остатки(&Дата, КостЦентр = &КостЦентр) КАК ВзаиморасчетыСПокупателямиОстатки";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("КостЦентр", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		текДвижение = Набор.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
			
		текДвижение = Набор.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
		текДвижение.КостЦентр = AU;
	КонецЦикла;	
	
КонецПроцедуры

Процедура СформироватьДвиженияОборудование() Экспорт
	
	Набор = Движения.Оборудование;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОборудованиеОстатки.Декларация,
	|	ОборудованиеОстатки.Номенклатура,
	|	ОборудованиеОстатки.AU,
	|	ОборудованиеОстатки.НомерСтрокиГТД,
	|	ОборудованиеОстатки.НалоговыйПериод,
	|	ОборудованиеОстатки.СуммаОстаток КАК Сумма,
	|	ОборудованиеОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.Оборудование.Остатки(&Дата, AU = &КостЦентр) КАК ОборудованиеОстатки";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("КостЦентр", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		текДвижение = Набор.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
			
		текДвижение = Набор.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
		текДвижение.AU = AU;
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияОборудованиеАрендованное() Экспорт
	
	Набор = Движения.ОборудованиеАрендованное;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОборудованиеАрендованноеОстатки.Декларация,
	|	ОборудованиеАрендованноеОстатки.Номенклатура,
	|	ОборудованиеАрендованноеОстатки.AU,
	|	ОборудованиеАрендованноеОстатки.НомерСтрокиГТД,
	|	ОборудованиеАрендованноеОстатки.Контрагент,
	|	ОборудованиеАрендованноеОстатки.НалоговыйПериод,
	|	ОборудованиеАрендованноеОстатки.СуммаОстаток КАК Сумма,
	|	ОборудованиеАрендованноеОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.ОборудованиеАрендованное.Остатки(&Дата, AU = &AU) КАК ОборудованиеАрендованноеОстатки";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("AU", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		текДвижение = Набор.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
			
		текДвижение = Набор.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
		текДвижение.AU = AU;
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияОборудованиеЛокальное() Экспорт
	
	Набор = Движения.ОборудованиеЛокальное;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОборудованиеЛокальноеОстатки.НомерНакладной,
	|	ОборудованиеЛокальноеОстатки.Поставщик,
	|	ОборудованиеЛокальноеОстатки.AU,
	|	ОборудованиеЛокальноеОстатки.РО,
	|	ОборудованиеЛокальноеОстатки.ДатаНакладной,
	|	ОборудованиеЛокальноеОстатки.Подразделение,
	|	ОборудованиеЛокальноеОстатки.СуммаОстаток КАК Сумма
	|ИЗ
	|	РегистрНакопления.ОборудованиеЛокальное.Остатки(&Дата, AU = &AU) КАК ОборудованиеЛокальноеОстатки";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("AU", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		текДвижение = Набор.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
			
		текДвижение = Набор.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
		текДВижение.AU = AU;
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияОборудованиеЭкспорт() Экспорт
	
	Набор = Движения.ОборудованиеЭкспорт;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ОборудованиеЭкспортОстатки.Декларация,
	|	ОборудованиеЭкспортОстатки.Номенклатура,
	|	ОборудованиеЭкспортОстатки.AU,
	|	ОборудованиеЭкспортОстатки.НомерСтрокиГТД,
	|	ОборудованиеЭкспортОстатки.НалоговыйПериод,
	|	ОборудованиеЭкспортОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.ОборудованиеЭкспорт.Остатки(&Дата, AU = &AU) КАК ОборудованиеЭкспортОстатки";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("AU", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		текДвижение = Набор.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
			
		текДвижение = Набор.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
		текДВижение.AU = AU;
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьДвиженияInventoryBatches() Экспорт
	
	Набор = Движения.InventoryBatches;
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	InventoryBatchesОстатки.Good,
	|	InventoryBatchesОстатки.InventoryLocation,
	|	InventoryBatchesОстатки.AU,
	|	InventoryBatchesОстатки.Batch,
	|	InventoryBatchesОстатки.FinishedGood,
	|	InventoryBatchesОстатки.Company,
	|	InventoryBatchesОстатки.TaxRegistration,
	|	InventoryBatchesОстатки.QuantityОстаток КАК Quantity,
	|	InventoryBatchesОстатки.SumОстаток КАК Sum
	|ИЗ
	|	РегистрНакопления.InventoryBatches.Остатки(&Дата, AU = &AU) КАК InventoryBatchesОстатки";
	Запрос.УстановитьПараметр("Дата", МоментВремени());
	Запрос.УстановитьПараметр("AU", AUСтарый);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		текДвижение = Набор.ДобавитьРасход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
			
		текДвижение = Набор.ДобавитьПриход();
		ЗаполнитьЗначенияСвойств(текДвижение, Выборка);
		текДвижение.Период = Дата;
		текДВижение.AU = AU;
	КонецЦикла;
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Ссылка <> Неопределено И Дата <> Ссылка.Дата Тогда
		Для Каждого Движение Из Движения Цикл
			Если Движение.Записывать = Ложь Тогда // При работе формы набор может быть уже "потроган" (прочитан, модифицирован)
				// Набор никто не трогал
				Движение.Прочитать();
			КонецЕсли;
			ТаблицаДвижений = Движение.Выгрузить();
			ТаблицаДвижений.ЗаполнитьЗначения(Дата, "Период");
			Движение.Загрузить(ТаблицаДвижений);
			Движение.Записывать = Истина;
		КонецЦикла;
	КонецЕсли;
	
	Если Ссылка <> Неопределено И Ссылка.ПометкаУдаления <> ПометкаУдаления Тогда
		УстановитьАктивностьДвижений(НЕ ПометкаУдаления);
	ИначеЕсли ПометкаУдаления Тогда
		//запись помеченного на удаление документа с активными записями
		УстановитьАктивностьДвижений(Ложь);
	КонецЕсли;
	
КонецПроцедуры

// Процедура устанавливает/снимает признак активности движений документа
//
Процедура УстановитьАктивностьДвижений(ФлагАктивности)
	
	Для Каждого Движение Из Движения Цикл   
		Если Движение.Записывать = Ложь Тогда // При работе формы набор может быть уже "потроган" (прочитан, модифицирован)
			// Набор никто не трогал
			Движение.Прочитать();
		КонецЕсли;
		Для Каждого Строка Из Движение Цикл
			Если Строка.Активность = ФлагАктивности Тогда
				Продолжить;
			КонецЕсли;
			Строка.Активность = ФлагАктивности;
			Движение.Записывать = Истина;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры // УстановитьАктивностьДвижений()