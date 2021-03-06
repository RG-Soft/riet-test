#Если Клиент Тогда
	
Перем НП Экспорт;

Перем CписокСчетов;
Перем Сч50;
Перем Сч51;
Перем Сч52;
Перем Сч55;

Перем Сч76_01, Сч58_01, Сч58_02, Сч58_04, Сч58_05, Сч68, Сч69, Сч70, Сч91_02;
Перем Сч60_01, Сч60_21, Сч60_31, Сч62_02, Сч62_22, Сч62_32, Сч58_03, Сч60_02, Сч60_22, Сч60_32;

// Возвращает полное наименование элемента справочника, если у этого вида 
// справочников есть реквизит НаименованиеПолное.
// 
// Параметры:      
//    Элемент - элемент справочника, для которого нужно вернуть полное наименование
//
// Возвращаемое значение: 
//  Строка с полным наименованием.
//
Функция ПолноеНаименование(Элемент) Экспорт

	Если ОбщегоНазначения.ЗначениеНеЗаполнено(Элемент) Тогда
		Возврат "";

	ИначеЕсли Элемент.Метаданные().Реквизиты.Найти("НаименованиеПолное") = Неопределено Тогда
		Возврат Элемент.Наименование;;

	ИначеЕсли ОбщегоНазначения.ЗначениеНеЗаполнено(Элемент.НаименованиеПолное) Тогда
		Возврат Элемент.Наименование;

	Иначе
		Возврат Элемент.НаименованиеПолное;
	КонецЕсли;

КонецФункции

// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом
//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
//
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок = Ложь) Экспорт

	ДокументРезультат.Очистить();

	Макет = ПолучитьМакет("Отчет");

	ОбластьЗаголовок  = Макет.ПолучитьОбласть("Заголовок");

	ОбластьЗаголовок.Параметры.НачалоПериода       = Формат(ДатаНач, "ДФ=dd.MM.yyyy");
	ОбластьЗаголовок.Параметры.КонецПериода        = Формат(ДатаКон, "ДФ=dd.MM.yyyy");
	ОбластьЗаголовок.Параметры.НазваниеОрганизации = Организация.НаименованиеПолное;
	ОбластьЗаголовок.Параметры.ИННОрганизации      = "" + Организация.ИНН + "/" + Организация.КПП;
	ДокументРезультат.Вывести(ОбластьЗаголовок);

	// Параметр для показа заголовка
	ВысотаЗаголовка = ДокументРезультат.ВысотаТаблицы;

	// Когда нужен только заголовок:
	Если ТолькоЗаголовок Тогда
		Возврат;
	КонецЕсли;

	Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;

	ОбластьПодвал        = Макет.ПолучитьОбласть("Подвал");
	ОбластьШапкаТаблицы  = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьПодвалТаблицы = Макет.ПолучитьОбласть("ПодвалТаблицы");
	ОбластьСтрока        = Макет.ПолучитьОбласть("Строка");

	ДокументРезультат.Вывести(ОбластьШапкаТаблицы);

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация",  Организация);
	Запрос.УстановитьПараметр("СписокСчетов", CписокСчетов);
	Запрос.УстановитьПараметр("ДатаНач",      НачалоДня(ДатаНач));
	Запрос.УстановитьПараметр("ДатаКон",      КонецДня(ДатаКон));

	Запрос.Текст = "ВЫБРАТЬ
	|	ХозрасчетныйОборотыДтКт.ВалютнаяСуммаОборотКт КАК ВалСумма,
	|	ХозрасчетныйОборотыДтКт.СуммаОборот КАК Сумма,
	|	ХозрасчетныйОборотыДтКт.ВалютаКт КАК Валюта,
	|	ХозрасчетныйОборотыДтКт.СчетДт КАК Счет,
	|	ХозрасчетныйОборотыДтКт.СубконтоДт1 КАК Субконто1,
	|	ХозрасчетныйОборотыДтКт.СубконтоДт2 КАК Субконто2,
	|	ХозрасчетныйОборотыДтКт.СубконтоДт3 КАК Субконто3,
	|	ХозрасчетныйОборотыДтКт.Период КАК ДатаОперации,
	|	ХозрасчетныйОборотыДтКт.Регистратор,
	|	ХозрасчетныйОборотыДтКт.Организация,
	|	ХозрасчетныйОборотыДтКт.НомерСтроки,
	|	Хозрасчетный.Регистратор КАК Регистратор1,
	|	Хозрасчетный.НомерСтроки,
	|	Хозрасчетный.Содержание
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный КАК Хозрасчетный
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(&ДатаНач, &ДатаКон, Запись, , , СчетКт В ИЕРАРХИИ (&СписокСчетов), , Организация = &Организация) КАК ХозрасчетныйОборотыДтКт
	|		ПО ХозрасчетныйОборотыДтКт.Регистратор = Хозрасчетный.Регистратор И ХозрасчетныйОборотыДтКт.НомерСтроки = Хозрасчетный.НомерСтроки
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаОперации";

	Результат = Запрос.Выполнить();
	Выборка   = Результат.Выбрать();

	ИтогСумма = 0;

	Пока Выборка.Следующий() Цикл

		ОбластьСтрока.Параметры.Дата        = Формат(Выборка.ДатаОперации, "ДФ=dd.MM.yyyy");
		ОбластьСтрока.Параметры.Сумма       = Выборка.Сумма;
		ОбластьСтрока.Параметры.ВалСумма    = Выборка.ВалСумма;
		ОбластьСтрока.Параметры.Валюта      = Выборка.Валюта;
		ОбластьСтрока.Параметры.Расшифровка = Выборка.Регистратор;

		ИтогСумма  = ИтогСумма + Выборка.Сумма;
		Контрагент = Справочники.Контрагенты.ПустаяСсылка();
		Договор    = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();

		Для НомерСубконто = 1 по 3 Цикл

			ЗначениеСубконто = Выборка["Субконто" + НомерСубконто];

			Если ТипЗнч(ЗначениеСубконто) = Тип("СправочникСсылка.Контрагенты") Тогда
				Контрагент = ЗначениеСубконто;

			ИначеЕсли ТипЗнч(ЗначениеСубконто) = Тип("СправочникСсылка.ДоговорыКонтрагентов") Тогда
				Договор = ЗначениеСубконто;

			КонецЕсли;

		КонецЦикла;

		ТекДок = Выборка.Регистратор.Метаданные().Синоним + " № " + Выборка.Регистратор.Номер;

		// определяем основание поступления денежных средств
		Если ОбщегоНазначения.ЗначениеНеЗаполнено(Договор) Тогда

			ОснованиеРасхода = СокрЛП(Выборка.Содержание) + " на основании: " + ТекДок;

		Иначе

			ОснованиеРасхода = ПолноеНаименование(Контрагент);
			ОснованиеРасхода = ОснованиеРасхода + ", " + Договор;
			ОснованиеРасхода = ОснованиеРасхода + ", на основании: " + ТекДок;

		КонецЕсли;

		ОбластьСтрока.Параметры.ОснованиеРасхода = ОснованиеРасхода;

		// Условие и вид расхода денежных средств
		Если Выборка.Счет = Сч76_01 Тогда

			УсловиеРасхода = "";
			ВидРасхода     = "Имущественное и личное страхование";

		ИначеЕсли (Выборка.Счет = Сч60_02) или (Выборка.Счет = Сч60_22) или (Выборка.Счет = Сч60_32) Тогда

			УсловиеРасхода = "Аванс выданный";
			ВидРасхода     = "";

		ИначеЕсли (Выборка.Счет = Сч60_01) или (Выборка.Счет = Сч60_21) или (Выборка.Счет = Сч60_31) Тогда

			УсловиеРасхода = "Оплата ранее полученного имущества, работ, услуг прав";
			ВидРасхода     = "";

		ИначеЕсли (Выборка.Счет = Сч62_02) или (Выборка.Счет = Сч62_22) или (Выборка.Счет = Сч62_32) Тогда
			УсловиеРасхода = "Возврат ранее полученных авансов";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч58_01 Тогда
			УсловиеРасхода = "Приобретение паев и акций";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч58_02 Тогда
			УсловиеРасхода = "Приобретение ценных бумаг";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч58_03 Тогда
			УсловиеРасхода = "На условиях возврата";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч58_04 Тогда
			УсловиеРасхода = "Вклады в простое товарищество";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч58_05 Тогда
			УсловиеРасхода = "Приобретение имущественных прав";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет.ПринадлежитЭлементу(Сч68) или Выборка.Счет.ПринадлежитЭлементу(Сч69) Тогда
			УсловиеРасхода = "Обязательные платежи в бюджет и внебюджетные фонды";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч70 Тогда
			УсловиеРасхода = "Оплата труда";
			ВидРасхода     = "";

		ИначеЕсли Выборка.Счет = Сч91_02 Тогда

			// Необходим анализ вида расхода
			Если (Выборка.Субконто1.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.РасходыНаУслугиБанков) Тогда
				УсловиеРасхода = "";
				ВидРасхода     = "Услуги банков";

			ИначеЕсли (Выборка.Субконто1.ВидПрочихДоходовИРасходов = Перечисления.ВидыПрочихДоходовИРасходов.ДоходыРасходыНеУчитываемыеВЦеляхНалогообложения) Тогда
				УсловиеРасхода = "Прочие расходы, не принимаемые для налогообложения";
				ВидРасхода     = "";

			Иначе
				УсловиеРасхода = "Прочие расходы, не связанные с движением задолженности";
				ВидРасхода     = "";

			КонецЕсли;

		ИначеЕсли Выборка.Счет.ПринадлежитЭлементу(Сч50) или (Выборка.Счет = Сч51) или (Выборка.Счет = Сч52) или Выборка.Счет.ПринадлежитЭлементу(Сч55) Тогда
			УсловиеРасхода = "Внутреннее перемещение (из кассы в банк и т.п.)";
			ВидРасхода     = "";

		ИначеЕсли Не Контрагент.Пустая() Тогда
			УсловиеРасхода = "Прочие расходы, связанные с движением задолженности";
			ВидРасхода     = "";

		Иначе

			УсловиеРасхода = "Прочие расходы, не связанные с движением задолженности";
			ВидРасхода     = "";

		КонецЕсли;

		ОбластьСтрока.Параметры.УсловиеРасхода = УсловиеРасхода;
		ОбластьСтрока.Параметры.ВидРасхода = ВидРасхода;

		ДокументРезультат.Вывести(ОбластьСтрока);

	КонецЦикла;

	СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, ДатаКон);
	ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = ПроцедурыУправленияПерсоналом.ФамилияИнициалыФизЛица(СтруктураЛиц.ОтветственныйЗаРегистры);

	ОбластьПодвалТаблицы.Параметры.ИтогСумма = ИтогСумма;

	ДокументРезультат.Вывести(ОбластьПодвалТаблицы);
	ДокументРезультат.Вывести(ОбластьПодвал);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

НП   = Новый НастройкаПериода;

Сч50 = ПланыСчетов.Хозрасчетный.Касса;
Сч51 = ПланыСчетов.Хозрасчетный.РасчетныеСчета;
Сч52 = ПланыСчетов.Хозрасчетный.ВалютныеСчета;
Сч55 = ПланыСчетов.Хозрасчетный.СпециальныеСчета;

CписокСчетов = Новый СписокЗначений;
CписокСчетов.Добавить(Сч50);
CписокСчетов.Добавить(Сч51);
CписокСчетов.Добавить(Сч52);
CписокСчетов.Добавить(Сч55);

Сч60_01 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("60.01");
Сч60_21 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("60.21");
Сч60_31 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("60.31");
Сч62_02 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("62.02");
Сч62_22 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("62.22");
Сч62_32 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("62.32");
Сч58_03 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("58.03");
Сч60_02 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("60.02");
Сч60_22 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("60.22");
Сч60_32 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("60.32");

Сч76_01 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("76.01");
Сч58_01 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("58.01");
Сч58_02 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("58.02");
Сч58_04 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("58.04");
Сч58_05 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("58.05");
Сч68    = ПланыСчетов.Хозрасчетный.НайтиПоКоду("68");
Сч69    = ПланыСчетов.Хозрасчетный.НайтиПоКоду("69");
Сч70    = ПланыСчетов.Хозрасчетный.НайтиПоКоду("70");
Сч91_02 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("91.02");

#КонецЕсли