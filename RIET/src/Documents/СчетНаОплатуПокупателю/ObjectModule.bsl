Перем мВалютаРегламентированногоУчета Экспорт;
Перем мСписокТикетов Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда
Функция ВернутьРасчетныйСчет(СчетКонтрагента)

	БанкДляРасчетов = СчетКонтрагента.БанкДляРасчетов;
	Результат       = ?(БанкДляРасчетов.Пустая(), СчетКонтрагента.НомерСчета, СчетКонтрагента.Банк.КоррСчет);

	Возврат Результат;

КонецФункции // ВернутьРасчетныйСчет()

//добавила Федотова Л., РГ-Софт, 10.08.10 ->
Функция ПолучитьПараметрыПечатиСчета()
	
	ПараметрыПечати = Новый Структура;
	ПараметрыПечати.Вставить("ВыводитьСкидку", Ложь);
	ПараметрыПечати.Вставить("ПроцентСкидки", 20);
	Возврат ПараметрыПечати;
	
КонецФункции // ПолучитьПараметрыПечатиСчета
//<-
#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	//[РКХ->]   
	Если ОбщегоНазначенияПовтИсп.ИдентификаторРабочейКонфигурации() = "PA" Тогда
		//Возврат Новый Структура("Счет, Инвойс, ИнвойсРус","Счет на оплату","Инвойс","Инвойс (рус.)"); 
		//изменила Федотова Л., РГ-Софт, 10.08.10
		//изменила Федотова Л., РГ-Софт, 10.08.10
		//Возврат Новый Структура("Счет, Счет, Инвойс, ИнвойсРус, ИнвойсРусСНастройкой","Счет на оплату", "Инвойс","Инвойс (рус.)", "Инвойс рус. (настройка)");
		Возврат Новый Структура("Счет, Счет, ИнвойсРус, ИнвойсРусСНастройкой","Счет на оплату", "Инвойс","Инвойс (рус.)", "Инвойс рус. (настройка)");
	Иначе
		//Возврат Новый Структура("Счет, Инвойс, ИнвойсРус","Счет на оплату","Инвойс","Инвойс (рус.)"); 
		//изменила Федотова Л., РГ-Софт, 10.08.10
		Возврат Новый Структура("Счет, Счет, Инвойс, ИнвойсРус, ИнвойсРусСНастройкой","Счет на оплату", "Инвойс","Инвойс (рус.)", "Инвойс рус. (настройка)");
	КонецЕсли;
	//[<-РКХ]
	
КонецФункции // ПолучитьСтруктуруПечатныхФорм()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

// Процедура - обработчик события "ОбработкаЗаполнения".
//
Процедура ОбработкаЗаполнения(Основание)
	
	Если Основание = Неопределено ИЛИ ТипЗнч(Основание) = Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ДокументОснование = Основание.ССылка;
	
	//Если ТипЗнч(Основание) = Тип("ДокументСсылка.АктОбОказанииПроизводственныхУслуг") Тогда
	//	// Заполнение шапки
	//	ВалютаДокумента = Основание.ВалютаДокумента;
	//	ДоговорКонтрагента = Основание.ДоговорКонтрагента;
	//	Комментарий = Основание.Комментарий;
	//	Контрагент = Основание.Контрагент;
	//	КратностьВзаиморасчетов = Основание.КратностьВзаиморасчетов;
	//	КурсВзаиморасчетов = Основание.КурсВзаиморасчетов;
	//	Организация = Основание.Организация;
	//	Ответственный = Основание.Ответственный;
	//	СуммаВключаетНДС = Основание.СуммаВключаетНДС;
	//	СуммаДокумента = Основание.СуммаДокумента;
	//	ТипЦен = Основание.ТипЦен;
	//	УчитыватьНДС = Основание.УчитыватьНДС;
	//	ИнвойсинговыйЦентр = Основание.ИнвойсинговыйЦентр;
	//	
	//	Запрос = Новый Запрос();
	//	Запрос.УстановитьПараметр("Ссылка", Основание.Ссылка);
	//	Запрос.Текст = "ВЫБРАТЬ
	//	|	АктОбОказанииПроизводственныхУслугУслуги.Номенклатура,
	//	|	АктОбОказанииПроизводственныхУслугУслуги.СтавкаНДС,
	//	|	АктОбОказанииПроизводственныхУслугУслуги.Цена,
	//	|	СУММА(АктОбОказанииПроизводственныхУслугУслуги.Количество) КАК Количество,
	//	|	СУММА(АктОбОказанииПроизводственныхУслугУслуги.Сумма) КАК Сумма,
	//	|	СУММА(АктОбОказанииПроизводственныхУслугУслуги.СуммаНДС) КАК СуммаНДС
	//	|ИЗ
	//	|	Документ.АктОбОказанииПроизводственныхУслуг.Услуги КАК АктОбОказанииПроизводственныхУслугУслуги
	//	|ГДЕ
	//	|	АктОбОказанииПроизводственныхУслугУслуги.Ссылка = &Ссылка
	//	|
	//	|СГРУППИРОВАТЬ ПО
	//	|	АктОбОказанииПроизводственныхУслугУслуги.Номенклатура,
	//	|	АктОбОказанииПроизводственныхУслугУслуги.СтавкаНДС,
	//	|	АктОбОказанииПроизводственныхУслугУслуги.Цена";
	//	ВыборкаУслуг = Запрос.Выполнить().Выбрать();
	//	
	//	Пока ВыборкаУслуг.Следующий() Цикл
	//		
	//		НоваяСтрока = Услуги.Добавить();
	//		НоваяСтрока.Количество = ВыборкаУслуг.Количество;
	//		НоваяСтрока.Номенклатура = ВыборкаУслуг.Номенклатура;
	//		НоваяСтрока.СтавкаНДС = ВыборкаУслуг.СтавкаНДС;
	//		НоваяСтрока.Сумма = ВыборкаУслуг.Сумма;
	//		НоваяСтрока.СуммаНДС = ВыборкаУслуг.СуммаНДС;
	//		НоваяСтрока.Цена = ВыборкаУслуг.Цена;
	//	КонецЦикла;
	//Иначе
	//
	//Если ТипЗнч(Основание) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		
		// Заполним реквизиты шапки по документу основанию.
		АдресДоставки = Основание.АдресДоставки;

		// Заполним реквизиты из стандартного набора по документу основанию.
		ОбщегоНазначения.ЗаполнитьШапкуДокументаПоОснованию(ЭтотОбъект, Основание);
		
		// Закомментировал РГ-Софт - Иванов Антон - 2010-03-15
		// Непонятно зачем этот реквизит вообще нужен
		//Реализация = Основание.Ссылка;
		
		Ответственный = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ПараметрыСеанса.ТекущийПользователь, "ОсновнойОтветственный");
        Утвердил = Основание.Руководитель;
		Если СокрЛП(ДоговорКонтрагента.Условия) = "" Тогда
			СтруктураОплаты = SalesBook.ПолучитьСрокОплатыИПроцент(Основание.Ссылка);
			Процент = СтруктураОплаты.Процент;
			ДнейНаОплату = СтруктураОплаты.СрокОплаты;
		КонецЕсли;
		//заполнение AU
		Если Основание.Товары.Количество() > 0 Тогда
			КостЦентр = Основание.Товары[0].КостЦентр;
		ИначеЕсли Основание.Услуги.Количество() > 0 Тогда		
			КостЦентр = Основание.Услуги[0].КостЦентр;		
		КонецЕсли;
		
		ПодразделениеОрганизации = Основание.ПодразделениеОрганизации;
		Дата = Основание.Дата;
		Если ОбщегоНазначения.ЗначениеНеЗаполнено(Основание.НомерСчетаНаОплату) Тогда
			Запрос = Новый Запрос("ВЫБРАТЬ
			                       |	СчетФактураВыданный.Номер
			                       |ИЗ
			                       |	Документ.СчетФактураВыданный КАК СчетФактураВыданный
			                       |ГДЕ
			                       |	СчетФактураВыданный.ДокументОснование = &ДокументОснование");
			Запрос.УстановитьПараметр("ДокументОснование", Основание.Ссылка);
			Выборка = запрос.Выполнить().Выбрать();
			Если Выборка.Следующий() Тогда
				
				Номер = Выборка.Номер;
			КонецЕсли;
		Иначе
			Номер = Основание.НомерСчетаНаОплату;	
		КонецЕсли;
		СтруктурнаяЕдиница = Основание.БанковскийСчетОрганизации;	
		ВидОперации = Перечисления.ВидыОперацийСчетНаОплатуПокупателю.СчетНаОплату;
		Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
		                      |	ВложенныйЗапрос.Ticket
		                      |ИЗ
		                      |	(ВЫБРАТЬ РАЗЛИЧНЫЕ
		                      |		РеализацияТоваровУслугТовары.Ticket КАК Ticket
		                      |	ИЗ
		                      |		Документ.РеализацияТоваровУслуг.Товары КАК РеализацияТоваровУслугТовары
		                      |	ГДЕ
		                      |		РеализацияТоваровУслугТовары.Ссылка = &Ссылка
		                      |	
		                      |	ОБЪЕДИНИТЬ ВСЕ
		                      |	
		                      |	ВЫБРАТЬ РАЗЛИЧНЫЕ
		                      |		РеализацияТоваровУслугУслуги.Ticket
		                      |	ИЗ
		                      |		Документ.РеализацияТоваровУслуг.Услуги КАК РеализацияТоваровУслугУслуги
		                      |	ГДЕ
		                      |		РеализацияТоваровУслугУслуги.Ссылка = &Ссылка) КАК ВложенныйЗапрос");
		Запрос.УстановитьПараметр("Ссылка", Основание.Ссылка);
		мСписокТикетов = Новый СписокЗначений;
		мСписокТикетов.ЗагрузитьЗначения(Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ticket"));

		Если ОбщегоНазначения.ЕстьРеквизитДокумента("ОтражатьВНалоговомУчете", Основание.Метаданные()) Тогда
			ОтражатьВНалоговомУчете = Основание.ОтражатьВНалоговомУчете;
		КонецЕсли;

		// Сделку и табличные части заполняем только если взаиморасчеты ведутся не по расчетным документам.
		СкопироватьТовары(Основание);
		СкопироватьУслуги(Основание);

//	КонецЕсли;


КонецПроцедуры // ОбработкаЗаполнения()

// Процедура вызывается перед записью документа 
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	// Если договор с комиссионером, то надо почистить закладку "Услуги".
	Если Услуги.Количество() > 0
	   И ДоговорКонтрагента.ВидДоговора = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером Тогда

		Услуги.Очистить();

	КонецЕсли;

	// Посчитать суммы документа и записать ее в соответствующий реквизит шапки для показа в журналах
	СуммаДокумента = ОбщегоНазначения.ПолучитьСуммуДокументаСНДС(ЭтотОбъект);  

КонецПроцедуры // ПередЗаписью

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ОбщегоНазначения.ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура СкопироватьТовары(Основание) Экспорт

	//изменил Трефиленков Дмитрий, РГ-Софт, Sales book
	ИмяДокумента = Основание.Метаданные().Имя;
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Основание);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	" + ИмяДокумента + "Товары.Номенклатура,
	|	" + ИмяДокумента + "Товары.ЕдиницаИзмерения,
	|	" + ИмяДокумента + "Товары.Цена,
	|	" + ИмяДокумента + "Товары.Сумма,
	|	" + ИмяДокумента + "Товары.СтавкаНДС,
	|	" + ИмяДокумента + "Товары.СуммаНДС,
	|	" + ИмяДокумента + "Товары.Коэффициент,
	|	" + ИмяДокумента + "Товары.Количество,
	|	" + ИмяДокумента + "Товары.КоличествоМест,
	|	" + ИмяДокумента + "Товары.Oilfield,
	|	" + ИмяДокумента + "Товары.КостЦентр,
	|	" + ИмяДокумента + "Товары.Ticket,
	|	" + ИмяДокумента + "Товары.TicketNumber КАК SIR,
	|	" + ИмяДокумента + "Товары.WO,
	|	" + ИмяДокумента + "Товары.ProductLine,
	|	" + ИмяДокумента + "Товары.Well
	|ИЗ
	|	Документ." + ИмяДокумента + ".Товары КАК " + ИмяДокумента + "Товары
	|
	|ГДЕ
	|	" + ИмяДокумента + "Товары.Ссылка = &Ссылка
	| Упорядочить по " + ИмяДокумента + "Товары.НомерСтроки";
	Товары.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

Процедура СкопироватьУслуги(Основание) Экспорт

	//изменил Трефиленков Дмитрий, РГ-Софт, Sales book
	ИмяДокумента = Основание.Метаданные().Имя;
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Основание);
	Запрос.Текст = "
	|ВЫБРАТЬ
	|	" + ИмяДокумента + "Услуги.НомерСтроки,
	|	" + ИмяДокумента + "Услуги.Содержание,
	|	" + ИмяДокумента + "Услуги.СодержаниеEng,
	|	" + ИмяДокумента + "Услуги.Количество,
	|	" + ИмяДокумента + "Услуги.Цена,
	|	" + ИмяДокумента + "Услуги.Сумма,
	|	" + ИмяДокумента + "Услуги.СтавкаНДС,
	|	" + ИмяДокумента + "Услуги.СуммаНДС,
	|	" + ИмяДокумента + "Услуги.Номенклатура,
	|	" + ИмяДокумента + "Услуги.Oilfield,
	|	" + ИмяДокумента + "Услуги.КостЦентр,
	|	" + ИмяДокумента + "Услуги.Ticket,
	|	" + ИмяДокумента + "Услуги.WO,
	|	" + ИмяДокумента + "Услуги.TicketNumber КАК SIR,
	|	" + ИмяДокумента + "Услуги.ProductLine,
	|	" + ИмяДокумента + "Услуги.Well
	|ИЗ
	|	Документ." + ИмяДокумента + ".Услуги КАК " + ИмяДокумента + "Услуги
	|
	|ГДЕ
	|	" + ИмяДокумента + "Услуги.Ссылка = &Ссылка
	| Упорядочить по " + ИмяДокумента + "Услуги.НомерСтроки";
	Услуги.Загрузить(Запрос.Выполнить().Выгрузить());
	//конец изменения

КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Если ВидОперации = Перечисления.ВидыОперацийСчетНаОплатуПокупателю.ПредоплатаПоДоговору Тогда
		Запись = Движения.СчетаНаПредоплату.Добавить();
		Запись.ВидДвижения = ВидДвиженияНакопления.Приход;
		Запись.ДоговорКонтрагента = ДоговорКонтрагента;
		Запись.Период = Дата;
		Запись.ПодразделениеОрганизации = ПодразделениеОрганизации;
		Запись.СуммаВзаиморасчетов = СуммаДокумента;
		Запись.СуммаРегл = СуммаДокумента*КурсВзаиморасчетов;
		Запись.СчетНаОплату = Ссылка;
		Движения.СчетаНаПредоплату.Записать();
	КонецЕсли;
	
КонецПроцедуры

мСписокТикетов = Неопределено;
мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();