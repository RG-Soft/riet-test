

Процедура ОбновитьДокументПоРазделуУчета(РазделУчета, СоответствиеРазделовУчета) Экспорт
	
	ТипДок = СоответствиеРазделовУчета.Получить(РазделУчета);
	//Если ТипДок
	
	Запрос = Новый Запрос;	
	Запрос.Текст = "ВЫБРАТЬ
	               |	СчетКнигиПокупок.Ссылка,
	               |	СУММА(ПроводкиDSSОбщие.BaseAmount) КАК Сумма,
	               |	СУММА(ВЫБОР
	               |			КОГДА ПроводкиDSSОбщие.GltObjId = 1000000000
	               |				ТОГДА 0
	               |			ИНАЧЕ ПроводкиDSSОбщие.BaseAmount
	               |		КОНЕЦ) КАК СуммаБезУчетаКорректировки,
	               |	ПроводкиDSSОбщие.Currency
	               |ИЗ
	               |	Документ.СчетКнигиПокупок КАК СчетКнигиПокупок
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПроводкиDSSОбщие КАК ПроводкиDSSОбщие
	               |		ПО (ПроводкиDSSОбщие.Регистратор = СчетКнигиПокупок.Ссылка)
	               |ГДЕ
	               |	СчетКнигиПокупок.Дата МЕЖДУ &НачалоПериода И &ОкончаниеПериода
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	СчетКнигиПокупок.Ссылка,
	               |	ПроводкиDSSОбщие.Currency
	               |
	               |ИМЕЮЩИЕ
	               |	СУММА(ПроводкиDSSОбщие.BaseAmount) > 0";	
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	СчетКнигиПокупок.Ссылка,
	               |	СУММА(ПроводкиDSSОбщие.BaseAmount) КАК Сумма,
	               |	СУММА(ВЫБОР
	               |			КОГДА ПроводкиDSSОбщие.GltObjId = 1000000000 И ЛОЖЬ
	               |				ТОГДА 0
	               |			ИНАЧЕ ПроводкиDSSОбщие.BaseAmount
	               |		КОНЕЦ) КАК СуммаБезУчетаКорректировки,
	               |	ПроводкиDSSОбщие.Currency				   
	               |ИЗ
	               |	Документ." + ТипДок + "  КАК СчетКнигиПокупок
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПроводкиDSSОбщие КАК ПроводкиDSSОбщие
	               |		ПО ПроводкиDSSОбщие.Регистратор = СчетКнигиПокупок.Ссылка
	               |ГДЕ
	               |	СчетКнигиПокупок.Дата МЕЖДУ &НачалоПериода И &ОкончаниеПериода
				   |	И 1 = 1 
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	СчетКнигиПокупок.Ссылка,
	               |	ПроводкиDSSОбщие.Currency
				   
	               |ИМЕЮЩИЕ
	               |	СУММА(ВЫБОР
	               |			КОГДА ПроводкиDSSОбщие.GltObjId = 1000000000 И ЛОЖЬ
	               |				ТОГДА 0
	               |			ИНАЧЕ ПроводкиDSSОбщие.BaseAmount
	               |		КОНЕЦ) <> 0";
				   
				   Если ПоказыватьСкорректированные Тогда
				   		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ЛОЖЬ", "ИСТИНА");
				   КонецЕсли;
				   
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
	Запрос.УстановитьПараметр("ОкончаниеПериода", ОкончаниеПериода);
		
	ДокументыБезБаланса.Загрузить(Запрос.Выполнить().Выгрузить());

	
КонецПроцедуры

Процедура ДобавитьБалансировку(Ссылка, Сумма=0, Валюта) Экспорт
	
	СтрокаБалансировка = СтрокиБаланса.Добавить();
	СтрокаБалансировка.BaseAmount = Сумма;
	СтрокаБалансировка.ДокументСсылка = Ссылка;
	СтрокаБалансировка.Currency = Валюта;
	
КонецПроцедуры

Процедура ПровестиДокументы() Экспорт
	
	Отказ = ПроверитьЗаполнениеПолей();
	Если Отказ Тогда
		//Возврат;
	КонецЕсли;
	
	//Удалим все корректировки	
	Об = мТекущийДок.ПолучитьОбъект();
	ДвиженияDSS = Об.Движения.ПроводкиDSSОбщие;
	ДвиженияDSS.Прочитать();
	
	Кол = ДвиженияDSS.Количество();
	Сч = 0;
	Пока Истина Цикл
		Если ДвиженияDSS[Сч].GltObjId = 1000000000 Тогда
			ДвиженияDSS.Удалить(ДвиженияDSS[Сч]);
			Кол = Кол - 1;
		Иначе
			Сч = Сч + 1;
		КонецЕсли;
		Если Сч = Кол Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;	
	
	МассивСтрок = СтрокиБаланса.Выгрузить();
	Если МассивСтрок.Количество() = 0 Тогда
		ДвиженияDSS.Записать();
		Возврат;
	КонецЕсли;
	
	Для Каждого СтрокаБаланса Из МассивСтрок Цикл
		Если СтрокаБаланса.BaseAmount = 0 Тогда
			Продолжить;
		КонецЕсли;
		НовоеДвижение = ДвиженияDSS.Добавить();
		ЗаполнитьЗначенияСвойств(НовоеДвижение, СтрокаБаланса);
		НовоеДвижение.GltObjId = "1000000000";
		НовоеДвижение.Период = мТекущийДок.Дата;
	КонецЦикла;
	
	ДвиженияDSS.Записать();
	
	СтрокиБаланса.Очистить();
	
КонецПроцедуры

Функция ПроверитьЗаполнениеПолей()
	
	Массив = Новый Массив;
	Массив.Добавить("PeriodLawson");
	Массив.Добавить("AU");
	Массив.Добавить("AccountLawson");
	Массив.Добавить("Currency");
	
	Для Каждого СтрокаБаланса Из СтрокиБаланса Цикл
		Для Каждого Эл Из Массив Цикл
			Если НЕ ЗначениеЗаполнено(СтрокаБаланса[Эл]) Тогда
				Возврат ложь;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции


Функция ПолучитьДвиженияДокументаПоDSS(Ссылка) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ПроводкиDSSОбщие.Период,
	               |	ПроводкиDSSОбщие.Регистратор,
	               |	ПроводкиDSSОбщие.НомерСтроки,
	               |	ПроводкиDSSОбщие.Активность,
	               |	ПроводкиDSSОбщие.PeriodLawson,
	               |	ПроводкиDSSОбщие.AccountLawson,
	               |	ПроводкиDSSОбщие.AU,
	               |	ПроводкиDSSОбщие.LegalEntity,
	               |	ПроводкиDSSОбщие.FiscalType,
	               |	ПроводкиDSSОбщие.Company,
	               |	ПроводкиDSSОбщие.Модуль,
	               |	ПроводкиDSSОбщие.BaseAmount,
	               |	ПроводкиDSSОбщие.RubAmount,
	               |	ПроводкиDSSОбщие.FiscAmount,
	               |	ПроводкиDSSОбщие.TempDiff,
	               |	ПроводкиDSSОбщие.PermDiff,
	               |	ПроводкиDSSОбщие.ExchDiff,
	               |	ПроводкиDSSОбщие.GltObjId,
	               |	ПроводкиDSSОбщие.DateLawson,
	               |	ПроводкиDSSОбщие.Reference,
	               |	ПроводкиDSSОбщие.Description,
	               |	ПроводкиDSSОбщие.TranAmount,
	               |	ПроводкиDSSОбщие.Currency
	               |ИЗ
	               |	РегистрНакопления.ПроводкиDSSОбщие КАК ПроводкиDSSОбщие
	               |ГДЕ
	               |	ПроводкиDSSОбщие.Регистратор = &Ссылка
	               |	И ПроводкиDSSОбщие.GltObjId = 1000000000";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Возврат(Запрос.Выполнить().Выгрузить());
	
КонецФункции

Процедура ЗаполнитьБалансировку(Таблица, Ссылка) Экспорт
	
	Для Каждого СтрокаТаблицы Из Таблица Цикл		
		СтрокаБалансировка = СтрокиБаланса.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаБалансировка, СтрокаТаблицы);	
		СтрокаБалансировка.ДокументСсылка = Ссылка;

	КонецЦикла;
	
КонецПроцедуры























