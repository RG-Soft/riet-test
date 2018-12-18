/////////////////////////////////////////////////////////////
//ВЕРСИЯ ПРОЦЕДУР И ФУНКЦИЙ ОБЛАСТИ "ТиповаяБухгалтерия": БУХ. КОРП. 3.0.38.42 бета

#Область ТиповаяБухгалтерия

// Рассчитывает сумму НДС исходя из суммы и флагов налогообложения
//
// Параметры: 
//  Сумма            - число, сумма от которой надо рассчитывать налоги, 
//  СуммаВключаетНДС - булево, признак включения НДС в сумму ("внутри" или "сверху"),
//  СтавкаНДС        - число , процентная ставка НДС,
//
// Возвращаемое значение:
//  Число, полученная сумма НДС
//
Функция РассчитатьСуммуНДС(Сумма, СуммаВключаетНДС, СтавкаНДС) Экспорт

	Если СуммаВключаетНДС Тогда
		СуммаБезНДС = 100 * Сумма / (100 + СтавкаНДС);
		СуммаНДС = Сумма - СуммаБезНДС;
	Иначе
		СуммаБезНДС = Сумма;
	КонецЕсли;

	Если НЕ СуммаВключаетНДС Тогда
		СуммаНДС = СуммаБезНДС * СтавкаНДС / 100;
	КонецЕсли;
	
	Возврат СуммаНДС;

КонецФункции // РассчитатьСуммуНДС()

// Производит пересчет цен при изменении флагов учета налогов.
// Пересчет зависит от способа заполнения цен, при заполнении По ценам номенклатуры (при продаже) 
// хочется избегать ситуаций, когда компания  «теряет деньги» при пересчете налогов. 
// Поэтому если в документе флаг "Учитывать налог" выключен, то цены должны браться напрямую из справочника, 
// потому что хочется продавать по той же цене, независимо от режима налогообложения. 
// Например, если отпускная цена задана с НП для избежания ошибок округления, то это не значит, 
// что при отпуске без НП мы должны продать дешевле. Если же флаг учета налога в документе включен, 
// то цены должны пересчитываться при подстановке в документ: 
// налог должен включаться или не включаться в зависимости от флага включения налога в типе цен.
// При заполнении по ценам контрагентов (при покупке) хочется хранить цены поставщиков. 
// Поэтому нужно пересчитывать всегда по установленным флагам в документе и в типе цен. 
// Это гарантирует, что при записи цен в регистр и последующем их чтении, 
// например, при заполнении следующего документа, мы с точностью до ошибок округления при пересчете 
// получим те же самые цены.
//
// Параметры: 
//  Цена                - число, пересчитываемое значение цены, 
//  ЦенаВключаетНДС     - булево, определяет содержит ли переданное значение цены НДС,
//  СуммаВключаетНДС    - булево, определяет должно ли новое значение цены включать НДС,
//  СтавкаНДС           - число, ставка НДС, 
//
// Возвращаемое значение:
//  Число, новое значение цены.
//
Функция ПересчитатьЦенуПриИзмененииФлаговНалогов(Цена, ЦенаВключаетНДС,
						СуммаВключаетНДС, СтавкаНДС) Экспорт

	// Инициализация переменных
	НадоВключитьНДС  = Ложь;
	НадоИсключитьНДС = Ложь;
	НоваяЦена		 = Цена;

	Если СуммаВключаетНДС
		И (НЕ ЦенаВключаетНДС) Тогда
		
		// Надо добавлять НДС       
		НадоВключитьНДС = Истина;
	ИначеЕсли (НЕ СуммаВключаетНДС)
		И ЦенаВключаетНДС  Тогда
		
		// Надо исключать НДС       
		НадоИсключитьНДС = Истина;
	КонецЕсли;
		
	Если НадоИсключитьНДС Тогда
		НоваяЦена = (НоваяЦена * 100) / (100 + СтавкаНДС);
	КонецЕсли;

	Если НадоВключитьНДС Тогда
		НоваяЦена = (НоваяЦена * (100 + СтавкаНДС)) / 100;
	КонецЕсли;

	Возврат НоваяЦена;

КонецФункции // ПересчитатьЦенуПриИзмененииФлаговНалогов()

// Возвращает номер версии подсистемы НДС.
//
Функция Версия(Дата) Экспорт
	
	Если Дата < '20120101' Тогда
		Возврат 1;
	Иначе
		Возврат 2;
	КонецЕсли;	
	
КонецФункции

// Заполнение реквизитов формы в документе - основании выданного счета-фактуры.

Процедура ЗаполнитьРеквизитыФормыПроСчетФактуруВыданный(Форма, РеквизитыСФ = Неопределено, ТребуетсяВсегда = Ложь, СтруктураОтбора = Неопределено, ИмяРеквизитаСчетФактура = "СчетФактура", ИмяРеквизитаСсылка = "Ссылка") Экспорт
	
	Если РеквизитыСФ <> Неопределено Тогда
		ИсходныеДанные = РеквизитыСФ;
	ИначеЕсли ЗначениеЗаполнено(Форма[ИмяРеквизитаСчетФактура]) Тогда
		ИсходныеДанные = Форма[ИмяРеквизитаСчетФактура];
	Иначе
		ИсходныеДанные = Форма.Объект[ИмяРеквизитаСсылка];
	КонецЕсли;
	
	Если ТребуетсяВсегда Тогда
		ТребуетсяСчетФактура = Истина;
	Иначе
		ТребуетсяСчетФактура = Форма.ТребуетсяСчетФактура;
	КонецЕсли;
	
	ДанныеНадписи = ДанныеОСчетеФактуре(
		ИсходныеДанные,
		"Выданный",
		ТребуетсяСчетФактура,
		СтруктураОтбора);
		
	Форма[ИмяРеквизитаСчетФактура]             = ДанныеНадписи.СчетФактура;
	Форма["Надпись" + ИмяРеквизитаСчетФактура] = ДанныеНадписи.НадписьСчетФактура;
	
КонецПроцедуры

Процедура ЗаполнитьРеквизитыФормыПроСчетФактуруПолученный(Форма, РеквизитыСФ = Неопределено, ТребуетсяСчетФактура = Истина, СтруктураОтбора = Неопределено, ИмяРеквизитаСчетФактура = "СчетФактура", ИмяРеквизитаСсылка = "Ссылка") Экспорт
	
	Если РеквизитыСФ <> Неопределено Тогда
		ИсходныеДанные = РеквизитыСФ;
	ИначеЕсли ЗначениеЗаполнено(Форма[ИмяРеквизитаСчетФактура]) Тогда
		ИсходныеДанные = Форма[ИмяРеквизитаСчетФактура];
	Иначе
		ИсходныеДанные = Форма.Объект[ИмяРеквизитаСсылка];
	КонецЕсли;
	
	ДанныеНадписи = ДанныеОСчетеФактуре(ИсходныеДанные, "Полученный", ТребуетсяСчетФактура, СтруктураОтбора);
		
	Форма[ИмяРеквизитаСчетФактура]             = ДанныеНадписи.СчетФактура;
	Форма["Надпись" + ИмяРеквизитаСчетФактура] = ДанныеНадписи.НадписьСчетФактура;
		
КонецПроцедуры

// ИсходныеДанные - Структура, содержащая информацию о счете-фактуре см. УчетНДСВызовСервера.РеквизитыДляНадписиОСчетеФактуреВыданном()
//              или ДокументСсылка.СчетФактураВыданный 
//              или ДокументСсылка - основание счета-фактуры
//
// ВидСчетаФактуры - Строка - "Выданный" или "Полученный"
Функция ДанныеОСчетеФактуре(Знач ИсходныеДанные, ВидСчетаФактуры, ТребуетсяСФ, СтруктураОтбора = Неопределено)
	
	ДанныеНадписи = Новый Структура;
	ДанныеНадписи.Вставить("СчетФактура",        Неопределено);
	ДанныеНадписи.Вставить("НадписьСчетФактура", "");
	
	Если НЕ ТребуетсяСФ Тогда
		
		ДанныеНадписи.НадписьСчетФактура = ВернутьСтр("ru='Не требуется'");
		Возврат ДанныеНадписи;
		
	КонецЕсли;
	
	РеквизитыСФ = Неопределено;
	Если ТипЗнч(ИсходныеДанные) = Тип("Структура") Тогда
		
		РеквизитыСФ = ИсходныеДанные;
		
	ИначеЕсли ЗначениеЗаполнено(ИсходныеДанные) Тогда
		
		Если ВидСчетаФактуры = "Выданный" Тогда
			РеквизитыСФ = УчетНДСВызовСервера.РеквизитыДляНадписиОСчетеФактуреВыданном(ИсходныеДанные, СтруктураОтбора);
		Иначе
			РеквизитыСФ = УчетНДСВызовСервера.РеквизитыДляНадписиОСчетеФактуреПолученном(ИсходныеДанные, СтруктураОтбора);
		КонецЕсли;
			
	КонецЕсли;
		
	Если РеквизитыСФ = Неопределено Тогда
		ДанныеНадписи.Вставить("НадписьСчетФактура", ВернутьСтр("ru='Ввести счет-фактуру'"));
	Иначе
		ДанныеНадписи.Вставить("СчетФактура",        РеквизитыСФ.Ссылка);
		ДанныеНадписи.Вставить("НадписьСчетФактура", РеквизитыСФ.КраткоеПредставление);
	КонецЕсли;
	
	Возврат ДанныеНадписи;
		
КонецФункции

Процедура ДополнитьПараметрыСобытияЗаписьСчетаФактуры(ПараметрыЗаписи) Экспорт
	
	Если ТипЗнч(ПараметрыЗаписи) <> Тип("Структура") Тогда
		ПараметрыЗаписи = Новый Структура;
	КонецЕсли;
	
	Если Не ПараметрыЗаписи.Свойство("ДокументыОснования") Тогда
		ПараметрыЗаписи.Вставить("ДокументыОснования", Новый Массив);
	КонецЕсли;
	
	Если Не ПараметрыЗаписи.Свойство("РеквизитыСФ") Тогда
		ПараметрыЗаписи.Вставить("РеквизитыСФ", Неопределено);
	КонецЕсли;
	
КонецПроцедуры


// Документы по учету НДС для передачи в электронном виде

Функция ПолучитьКодПоСКНП(Период, Реорганизация = Ложь) Экспорт 
	
	Мес = Цел((Месяц(Период) - 1)/3);
	
	Если Реорганизация Тогда
		Если Мес = 0 Тогда
			Возврат "51";
		ИначеЕсли Мес = 1 Тогда 
			Возврат "54";
		ИначеЕсли Мес = 2 Тогда 
			Возврат "55";
		ИначеЕсли Мес = 3 Тогда 
			Возврат "56";
		КонецЕсли;
	Иначе
		Если Мес = 0 Тогда
			Возврат "21";
		ИначеЕсли Мес = 1 Тогда 
			Возврат "22";
		ИначеЕсли Мес = 2 Тогда 
			Возврат "23";
		ИначеЕсли Мес = 3 Тогда 
			Возврат "24";
		КонецЕсли;	
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

#КонецОбласти