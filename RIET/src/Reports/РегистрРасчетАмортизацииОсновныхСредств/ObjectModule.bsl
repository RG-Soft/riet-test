#Если Клиент Тогда
	
Перем НП Экспорт;

Перем ВидыРасходовПоСпособуАмортизации;
Перем CписокСчетов;
Перем ИтогСуммаАмортизации;
Перем СуммаАмортизацииПрямые экспорт;
Перем СуммаАмортизацииКосвенные Экспорт;
Перем СуммаАмортизацииПрочие Экспорт;
Перем СпособыРаспределенияРасходов Экспорт;
Перем СчетаПрямыхЗатрат;
Перем СчетаПрямыхИКосвенныхЗатрат;

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

Процедура ВывестиСтроку(Опер, ДокументРезультат, Макет)
	
	Если Опер.Амортизация = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Строка1 = Макет.ПолучитьОбласть("Строка|Общая1");
	Строка2 = Макет.ПолучитьОбласть("Строка|Объект");
	Строка3 = Макет.ПолучитьОбласть("Строка|Общая2");
	
	Строка1.Параметры.ДатаОперации = Формат(Опер.Период, "ДФ=dd.MM.yyyy");
	Строка3.Параметры.СпециальныйКоэффициент = Опер.СпециальныйКоэффициент;
	Строка3.Параметры.МетодНачисленияАмортизации = Опер.МетодНачисленияАмортизации;
	Строка2.Параметры.НаименованиеОбъекта = ПолноеНаименование(Опер.ОсновноеСредство);
	
	Если Опер.МетодНачисленияАмортизации = Перечисления.МетодыНачисленияАмортизации.Линейный Тогда
		Стоимость = Опер.ПервоначальнаяСтоимость;
		
	Иначе
		Стоимость = ?(Опер.ПервоначальнаяСтоимость = NULL, 0, Опер.ПервоначальнаяСтоимость) - ?(Опер.АмортизацияНач = NULL, 0, Опер.АмортизацияНач);
		Если Опер.РасчетПоБазовойСтоимости=Истина Тогда
			Стоимость = Опер.ПервоначальнаяСтоимость - Опер.АмортизацииДляБазовойСтоимости;
		КонецЕсли;
	КонецЕсли;
	
	КоличествоМесяцевПолезногоИспользованияНаНач = 0;
	ДатаПринятияКУчету = Опер.ДатаПринятияКУчету;
	
	Если ОбщегоНазначения.ЗначениеНеЗаполнено(ДатаПринятияКУчету) тогда
		КоличествоМесяцевПолезногоИспользованияНаНач = ?(Опер.СрокПолезногоИспользования = NUll, 0, Опер.СрокПолезногоИспользования);
	Иначе
		ТекДата = КонецМесяца(ДобавитьМесяц(ДатаПринятияКУчету, 1));
		ТекДатаНач = КонецМесяца(Опер.Период);
		Пока ТекДата < ТекДатаНач Цикл
			КоличествоМесяцевПолезногоИспользованияНаНач = КоличествоМесяцевПолезногоИспользованияНаНач + 1;
			ТекДата = КонецМесяца(ДобавитьМесяц(ТекДата, 1));
		КонецЦикла;
	КонецЕсли;
	
	Способ = СпособыРаспределенияРасходов.Найти(Опер.СпособОтраженияРасходов,"Способ");
	Если Способ=Неопределено тогда
		ПрочиеРасходы = Опер.Амортизация;
		ПрямыеРасходы = 0;
		КосвенныеРасходы = 0;
	Иначе
		БазисРаспределения = Новый Массив(3);
		БазисРаспределения[0] = Способ.ПрямыеЗатраты;
		БазисРаспределения[1] = Способ.КосвенныеЗатраты;
		БазисРаспределения[2] = Способ.ПрочиеЗатраты;
		Распределение = УправлениеПроизводством.РаспределитьПропорционально(Опер.Амортизация,БазисРаспределения);
		Если Распределение=Неопределено тогда
			ПрочиеРасходы = Опер.Амортизация;
			ПрямыеРасходы = 0;
			КосвенныеРасходы = 0;
		Иначе
			 ПрямыеРасходы	= Распределение[0];
			 КосвенныеРасходы	= Распределение[1];
			 ПрочиеРасходы	= Распределение[2];
		КонецЕсли;
	КонецЕсли;
	СуммаАмортизацииПрямые = СуммаАмортизацииПрямые + ПрямыеРасходы;
	СуммаАмортизацииКосвенные = СуммаАмортизацииКосвенные + КосвенныеРасходы;
	СуммаАмортизацииПрочие = СуммаАмортизацииПрочие + ПрочиеРасходы;
	
	
	Строка3.Параметры.Прямые	= ПрямыеРасходы;
	Строка3.Параметры.Косвенные	= КосвенныеРасходы;
	Строка3.Параметры.Прочие	= ПрочиеРасходы;
	
	Строка3.Параметры.Стоимость = Стоимость;
	Строка3.Параметры.ПолезныйСрок = макс(0,?(Опер.СрокПолезногоИспользования = NULL, 0, Опер.СрокПолезногоИспользования) - КоличествоМесяцевПолезногоИспользованияНаНач);
	Строка3.Параметры.СуммаАмортизации = ?(Опер.Амортизация = NULL, 0, Опер.Амортизация);

	ДокументРезультат.Вывести(Строка1);
	Если Не ГруппироватьПоОбъектам Тогда
		ДокументРезультат.Присоединить(Строка2);
	КонецЕсли;
	ДокументРезультат.Присоединить(Строка3);
	
	ИтогСуммаАмортизации = ИтогСуммаАмортизации + Опер.Амортизация;
	
КонецПроцедуры

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

	Если ГруппироватьПоОбъектам Тогда
		Заголовок1 = Макет.ПолучитьОбласть("Заголовок|Общая1");
		Заголовок2 = Макет.ПолучитьОбласть("Заголовок|Общая2");
		
	Иначе
		Заголовок1 = Макет.ПолучитьОбласть("Заголовок");
	КонецЕсли;
	
	Заголовок1.Параметры.НачалоПериода       = Формат(ДатаНач, "ДФ=dd.MM.yyyy");
	Заголовок1.Параметры.КонецПериода        = Формат(ДатаКон, "ДФ=dd.MM.yyyy");
	Заголовок1.Параметры.НазваниеОрганизации = Организация.НаименованиеПолное;
	Заголовок1.Параметры.ИННОрганизации      = "" + Организация.ИНН + "/" + Организация.КПП;
	Заголовок1.Параметры.НазваниеАмортизационнойГруппы = ?(ОбщегоНазначения.ЗначениеНеЗаполнено(АмортизационнаяГруппа), "по всем", АмортизационнаяГруппа);
	
	Если ГруппироватьПоОбъектам Тогда
		ДокументРезультат.Вывести(Заголовок1);
		ДокументРезультат.Присоединить(Заголовок2);
		
	Иначе
		ДокументРезультат.Вывести(Заголовок1);
	КонецЕсли;

	// Параметр для показа заголовка
	ВысотаЗаголовка = ДокументРезультат.ВысотаТаблицы;

	// Когда нужен только заголовок:
	Если ТолькоЗаголовок Тогда
		Возврат;
	КонецЕсли;

	Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;
	
	СуммаАмортизацииПрямые = 0;
	СуммаАмортизацииКосвенные = 0;
	СуммаАмортизацииПрочие = 0;
	// Шапка
	Если ГруппироватьПоОбъектам Тогда

		Шапка1 = Макет.ПолучитьОбласть("Шапка|Общая1");
		Шапка2 = Макет.ПолучитьОбласть("Шапка|Общая2");
		Шапка2.Параметры.НК2 = 2;
		Шапка2.Параметры.НК3 = 3;
		Шапка2.Параметры.НК4 = 4;
		Шапка2.Параметры.НК5 = 5;
		Шапка2.Параметры.НК6 = 6;

		ДокументРезультат.Вывести(Шапка1);
		ДокументРезультат.Присоединить(Шапка2);

	Иначе
		Шапка = Макет.ПолучитьОбласть("Шапка");
		Шапка.Параметры.НК2 = 3;
		Шапка.Параметры.НК3 = 4;
		Шапка.Параметры.НК4 = 5;
		Шапка.Параметры.НК5 = 6;
		Шапка.Параметры.НК6 = 7;
		ДокументРезультат.Вывести(Шапка);
	КонецЕсли;

	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ТаблицаАмортизации.СуммаОборотКт КАК Амортизация,
	|	ТаблицаАмортизации.Период,
	|	ПервоначальныеСведения.МетодНачисленияАмортизации,
	|	ПервоначальныеСведения.ПервоначальнаяСтоимостьНУ КАК ПервоначальнаяСтоимость,
	|	Коэффициент.СпециальныйКоэффициент,
	|	ВЫБОР
	|		КОГДА СостояниеОС.ДатаСостояния < &ДатаНачалаНУ
	|			ТОГДА &ДатаНачалаНУ
	|		ИНАЧЕ СостояниеОС.ДатаСостояния
	|	КОНЕЦ КАК ДатаПринятияКУчету,
	|	СпособОтражения.СпособыОтраженияРасходовПоАмортизации КАК СпособОтраженияРасходов,
	|	ПоБазовойСтоимости.ПризнакНачисленияПоБазовойСтоимости КАК РасчетПоБазовойСтоимости,
	|	ПоБазовойСтоимости.СуммаНакопленнойАмортизации КАК АмортизацииДляБазовойСтоимости,
	|	ТаблицаАмортизации.Субконто1 КАК ОсновноеСредство,
	|	Параметры.СрокПолезногоИспользования,
	|	ТаблицаАмортизации.СуммаОборотКт,
	|	НалоговыйОстатки.СуммаОстатокДт КАК АмортизацияНач
	|ИЗ
	|	РегистрБухгалтерии.Налоговый.Обороты(
	|		&ДатаНач,
	|		&ДатаКон,
	|		Регистратор,
	|		Счет В ИЕРАРХИИ (&Счет) И Не Счет = &Счет09,
	|		&ВидСубконто,
	|		Организация = &Организация
	|		    И ВидУчета = &ВидУчета
	|		    ,
	|		,
	|		) КАК ТаблицаАмортизации
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НачислениеАмортизацииОСПоБазовойСтоимостиНалоговыйУчет КАК ПоБазовойСтоимости
	|		ПО ТаблицаАмортизации.Субконто1 = ПоБазовойСтоимости.ОсновноеСредство
	|			И (ПоБазовойСтоимости.Период В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					МАКСИМУМ(УстановкаПараметров.Период)
	|				ИЗ
	|					РегистрСведений.НачислениеАмортизацииОСПоБазовойСтоимостиНалоговыйУчет КАК УстановкаПараметров
	|				ГДЕ
	|					УстановкаПараметров.Период < НАЧАЛОПЕРИОДА(ТаблицаАмортизации.Период, МЕСЯЦ)
	|					И УстановкаПараметров.ОсновноеСредство = ТаблицаАмортизации.Субконто1
	|					И УстановкаПараметров.Организация = &Организация))
	|			И ТаблицаАмортизации.Организация = ПоБазовойСтоимости.Организация
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПервоначальныеСведенияОСНалоговыйУчет КАК ПервоначальныеСведения
	|		ПО ТаблицаАмортизации.Субконто1 = ПервоначальныеСведения.ОсновноеСредство
	|			И (ПервоначальныеСведения.Период В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					МАКСИМУМ(УстановкаПараметров.Период)
	|				ИЗ
	|					РегистрСведений.ПервоначальныеСведенияОСНалоговыйУчет КАК УстановкаПараметров
	|				ГДЕ
	|					УстановкаПараметров.Период < НАЧАЛОПЕРИОДА(ТаблицаАмортизации.Период, МЕСЯЦ)
	|					И УстановкаПараметров.ОсновноеСредство = ТаблицаАмортизации.Субконто1
	|					И УстановкаПараметров.Организация = &Организация))
	|			И ТаблицаАмортизации.Организация = ПервоначальныеСведения.Организация
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НачислениеАмортизацииОССпециальныйКоэффициентНалоговыйУчет КАК Коэффициент
	|		ПО ТаблицаАмортизации.Субконто1 = Коэффициент.ОсновноеСредство
	|			И (Коэффициент.Период В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					МАКСИМУМ(УстановкаПараметров.Период)
	|				ИЗ
	|					РегистрСведений.НачислениеАмортизацииОССпециальныйКоэффициентНалоговыйУчет КАК УстановкаПараметров
	|				ГДЕ
	|					УстановкаПараметров.Период < НАЧАЛОПЕРИОДА(ТаблицаАмортизации.Период, МЕСЯЦ)
	|					И УстановкаПараметров.ОсновноеСредство = ТаблицаАмортизации.Субконто1
	|					И УстановкаПараметров.Организация = &Организация))
	|			И ТаблицаАмортизации.Организация = Коэффициент.Организация
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СостоянияОСОрганизаций КАК СостояниеОС
	|		ПО ТаблицаАмортизации.Субконто1 = СостояниеОС.ОсновноеСредство
	|			И (СостояниеОС.Состояние = &ПринятоКУчету)
	|			И (СостояниеОС.ДатаСостояния В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					МИНИМУМ(УстановкаПараметров.ДатаСостояния)
	|				ИЗ
	|					РегистрСведений.СостоянияОСОрганизаций КАК УстановкаПараметров
	|				ГДЕ
	|					УстановкаПараметров.ДатаСостояния < НАЧАЛОПЕРИОДА(ТаблицаАмортизации.Период, МЕСЯЦ)
	|					И УстановкаПараметров.ОсновноеСредство = ТаблицаАмортизации.Субконто1
	|					И УстановкаПараметров.Организация = &Организация
	|					И УстановкаПараметров.Состояние = &ПринятоКУчету))
	|			И ТаблицаАмортизации.Организация = СостояниеОС.Организация
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СпособыОтраженияРасходовПоАмортизацииОСНалоговыйУчет КАК СпособОтражения
	|		ПО ТаблицаАмортизации.Субконто1 = СпособОтражения.ОсновноеСредство
	|			И (СпособОтражения.Период В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					МАКСИМУМ(УстановкаПараметров.Период)
	|				ИЗ
	|					РегистрСведений.СпособыОтраженияРасходовПоАмортизацииОСНалоговыйУчет КАК УстановкаПараметров
	|				ГДЕ
	|					УстановкаПараметров.Период < НАЧАЛОПЕРИОДА(ТаблицаАмортизации.Период, МЕСЯЦ)
	|					И УстановкаПараметров.ОсновноеСредство = ТаблицаАмортизации.Субконто1
	|					И УстановкаПараметров.Организация = &Организация))
	|			И ТаблицаАмортизации.Организация = СпособОтражения.Организация
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПараметрыАмортизацииОСНалоговыйУчет КАК Параметры
	|		ПО ТаблицаАмортизации.Субконто1 = Параметры.ОсновноеСредство
	|			И (Параметры.Период В
	|				(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|					МАКСИМУМ(УстановкаПараметров.Период)
	|				ИЗ
	|					РегистрСведений.ПараметрыАмортизацииОСНалоговыйУчет КАК УстановкаПараметров
	|				ГДЕ
	|					УстановкаПараметров.Период < НАЧАЛОПЕРИОДА(ТаблицаАмортизации.Период, МЕСЯЦ)
	|					И УстановкаПараметров.ОсновноеСредство = ТаблицаАмортизации.Субконто1
	|					И УстановкаПараметров.Организация = &Организация))
	|			И ТаблицаАмортизации.Организация = Параметры.Организация
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Налоговый.Остатки(
	|		&ДатаКон,
	|		Счет В ИЕРАРХИИ (&Счет) И Не Счет = &Счет09,
	|		&ВидСубконто,
	|		Организация = &Организация
	|		    И ВидУчета = &ВидУчета) КАК НалоговыйОстатки
	|		ПО ТаблицаАмортизации.Организация = НалоговыйОстатки.Организация
	|			И ТаблицаАмортизации.Субконто1 = НалоговыйОстатки.Субконто1
	|ГДЕ
	|	СостояниеОС.Состояние = &ПринятоКУчету";

	
			
		Если ГруппироватьПоОбъектам Тогда
		ТекстЗапроса = 		ТекстЗапроса + "
		|ИТОГИ СУММА(Амортизация) ПО
		|	ОсновноеСредство";
	КонецЕсли;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация",     Организация);
	Запрос.УстановитьПараметр("ДатаНач",         ?(ОбщегоНазначения.ЗначениеНеЗаполнено(ДатаНач),ДатаНач,НачалоДня(ДатаНач)));
	Запрос.УстановитьПараметр("ДатаКон",         ?(ОбщегоНазначения.ЗначениеНеЗаполнено(ДатаКон),ДатаКон,КонецДня(ДатаКон)));
	Запрос.УстановитьПараметр("ПринятоКУчету", 	 Перечисления.СостоянияОС.ВведеноВЭксплуатацию);
	Запрос.УстановитьПараметр("ДатаНачалаНУ",    '20020101000000');
	Массив = Новый Массив;
	Массив.Добавить(ПланыСчетов.Налоговый.АмортизацияОсновныхСредств);
	Массив.Добавить(ПланыСчетов.Налоговый.ОсновныеСредства);
	Запрос.УстановитьПараметр("Счет",Массив);
	Запрос.УстановитьПараметр("Счет09",ПланыСчетов.Налоговый.ВыбытиеОС);
	Запрос.УстановитьПараметр("ВидУчета",Перечисления.ВидыУчетаПоПБУ18.НУ);
	Запрос.УстановитьПараметр("ВидСубконто",ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ОсновныеСредства);
	Запрос.Текст = ТекстЗапроса;
	
	СтруктураПоиска = Новый Структура;
	СтруктураПоиска.Вставить("Организация", Организация);
	
	ИтогСуммаАмортизации = 0;
	
	Если ГруппироватьПоОбъектам Тогда
		Опер = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
	Иначе
		Опер = Запрос.Выполнить().Выбрать();
	КонецЕсли;

	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	РаспределениеАмортизации.ТекущееНаправление КАК Способ,
		|	СУММА(РаспределениеАмортизации.БазаРаспределения) КАК БазаРаспределения,
		|	СУММА(РаспределениеАмортизации.ПрямыеЗатраты) КАК ПрямыеЗатраты,
		|	СУММА(РаспределениеАмортизации.КосвенныеЗатраты) КАК КосвенныеЗатраты,
		|	СУММА(РаспределениеАмортизации.ПрочиеЗатраты) КАК ПрочиеЗатраты
		|ИЗ
		|	(ВЫБРАТЬ РАЗЛИЧНЫЕ
		|		СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет.СпособыОтраженияРасходовПоАмортизации КАК СпособыОтраженияРасходовПоАмортизации
		|	ИЗ
		|		РегистрСведений.СпособыОтраженияРасходовПоАмортизацииОСНалоговыйУчет КАК СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет
		|	
		|	ГДЕ
		|		СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет.Организация = &Организация И
		|		СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет.Период > &ДатаНач И
		|		СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет.Период <= &ДатаКон
		|	
		|	ОБЪЕДИНИТЬ
		|	
		|	ВЫБРАТЬ РАЗЛИЧНЫЕ
		|		СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет.СпособыОтраженияРасходовПоАмортизации
		|	ИЗ
		|		РегистрСведений.СпособыОтраженияРасходовПоАмортизацииОСНалоговыйУчет.СрезПоследних(&ДатаНач, Организация = &Организация) КАК СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет
		|		) КАК СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет
		|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			НаправлениеНачисленияАмортизацииНаправления.Коэффициент КАК БазаРаспределения,
		|			ВЫБОР КОГДА НаправлениеНачисленияАмортизацииНаправления.СчетЗатратНУ В ИЕРАРХИИ (&СчетаПрямыхЗатрат) ТОГДА НаправлениеНачисленияАмортизацииНаправления.Коэффициент ИНАЧЕ 0 КОНЕЦ КАК ПрямыеЗатраты,
		|			ВЫБОР КОГДА НаправлениеНачисленияАмортизацииНаправления.СчетЗатратНУ В ИЕРАРХИИ (&СчетаПрямыхИКосвенныхЗатрат) И НЕ(НаправлениеНачисленияАмортизацииНаправления.СчетЗатратНУ В ИЕРАРХИИ (&СчетаПрямыхЗатрат)) ТОГДА НаправлениеНачисленияАмортизацииНаправления.Коэффициент ИНАЧЕ 0 КОНЕЦ КАК КосвенныеЗатраты,
		|			ВЫБОР КОГДА НЕ(НаправлениеНачисленияАмортизацииНаправления.СчетЗатратНУ В ИЕРАРХИИ (&СчетаПрямыхИКосвенныхЗатрат)) И НЕ(НаправлениеНачисленияАмортизацииНаправления.СчетЗатратНУ В ИЕРАРХИИ (&СчетаПрямыхЗатрат)) ТОГДА НаправлениеНачисленияАмортизацииНаправления.Коэффициент ИНАЧЕ 0 КОНЕЦ КАК ПрочиеЗатраты,
		|			НаправлениеНачисленияАмортизации.Ссылка КАК ТекущееНаправление,
		|			НаправлениеНачисленияАмортизации.Представление КАК Представление
		|		ИЗ
		|			Справочник.СпособыОтраженияРасходовПоАмортизации.Способы КАК НаправлениеНачисленияАмортизацииНаправления
		|				ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СпособыОтраженияРасходовПоАмортизации КАК НаправлениеНачисленияАмортизации
		|				ПО НаправлениеНачисленияАмортизацииНаправления.Ссылка = НаправлениеНачисленияАмортизации.Ссылка) КАК РаспределениеАмортизации
		|		ПО СпособыОтраженияРасходовПоАмортизацииНалоговыйУчет.СпособыОтраженияРасходовПоАмортизации = РаспределениеАмортизации.ТекущееНаправление
		|
		|СГРУППИРОВАТЬ ПО
		|	РаспределениеАмортизации.ТекущееНаправление";
		Запрос.УстановитьПараметр("СчетаПрямыхЗатрат",СчетаПрямыхЗатрат);
		Запрос.УстановитьПараметр("СчетаПрямыхИКосвенныхЗатрат",СчетаПрямыхИКосвенныхЗатрат);
		СпособыРаспределенияРасходов = Запрос.Выполнить().Выгрузить();
	
	Пока Опер.Следующий() Цикл
		Если (Опер.ОсновноеСредство.АмортизационнаяГруппа <> АмортизационнаяГруппа) и (не АмортизационнаяГруппа.Пустая()) Тогда
			Продолжить;
		КонецЕсли;

		Если ГруппироватьПоОбъектам Тогда

			Группировка1 = Макет.ПолучитьОбласть("Группировка|Общая1");
			Группировка3 = Макет.ПолучитьОбласть("Группировка|Общая2");

			Группировка1.Параметры.ЗначениеГруппировки = ПолноеНаименование(Опер.ОсновноеСредство);
			Группировка3.Параметры.ИтогСуммаПоГруппировке = Опер.Амортизация;

			ДокументРезультат.Вывести(Группировка1);
			ДокументРезультат.Присоединить(Группировка3);

			ОперПоОбъекту = Опер.Выбрать();
			Пока ОперПоОбъекту.Следующий() Цикл
				ВывестиСтроку(ОперПоОбъекту, ДокументРезультат, Макет);
			КонецЦикла;

		Иначе
			ВывестиСтроку(Опер, ДокументРезультат, Макет);
		КонецЕсли;
	КонецЦикла;

	// Подвал
	Если ГруппироватьПоОбъектам Тогда
		Подвал1 = Макет.ПолучитьОбласть("Подвал1|Общая1");
		Подвал2 = Макет.ПолучитьОбласть("Подвал1|Общая2");
		Подвал2.Параметры.ИтогСуммаАмортизации     = ИтогСуммаАмортизации;
		Подвал2.Параметры.СуммаПрямых		= СуммаАмортизацииПрямые;
		Подвал2.Параметры.СуммаКосвенных	= СуммаАмортизацииКосвенные;
		Подвал2.Параметры.СуммаПрочих		= СуммаАмортизациипрочие;
		ДокументРезультат.Вывести(Подвал1);
		ДокументРезультат.Присоединить(Подвал2);

	Иначе
		Подвал = Макет.ПолучитьОбласть("Подвал1");
		Подвал.Параметры.ИтогСуммаАмортизации     = ИтогСуммаАмортизации;
		Подвал.Параметры.СуммаПрямых		= СуммаАмортизацииПрямые;
		Подвал.Параметры.СуммаКосвенных	= СуммаАмортизацииКосвенные;
		Подвал.Параметры.СуммаПрочих		= СуммаАмортизациипрочие;
		ДокументРезультат.Вывести(Подвал);
	КонецЕсли;

	ОбластьПодвал = Макет.ПолучитьОбласть("Подвал");
	СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, ДатаКон);
	ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = ПроцедурыУправленияПерсоналом.ФамилияИнициалыФизЛица(СтруктураЛиц.ОтветственныйЗаРегистры);
	ДокументРезультат.Вывести(ОбластьПодвал);

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

НП = Новый НастройкаПериода;


СчетаПрямыхЗатрат =Новый Массив();
СчетаНалоговогоУчета = ПланыСчетов.Налоговый;
СчетаПрямыхЗатрат.Добавить(СчетаНалоговогоУчета.ПрямыеРасходыОсновногоПроизводства);
СчетаПрямыхЗатрат.Добавить(СчетаНалоговогоУчета.ПрямыеРасходыВспомогательныхПроизводств);
СчетаПрямыхЗатрат.Добавить(СчетаНалоговогоУчета.ПрямыеОбщепроизводственныеРасходы);
СчетаПрямыхЗатрат.Добавить(СчетаНалоговогоУчета.ПрямыеРасходыОбслуживающихПроизводств);
СчетаПрямыхЗатрат.Добавить(СчетаНалоговогоУчета.ПрямыеОбщехозяйственныеРасходы);

СчетаПрямыхИКосвенныхЗатрат = Новый Массив();
СчетаПрямыхИКосвенныхЗатрат.Добавить(СчетаНалоговогоУчета.ОсновноеПроизводство_);
СчетаПрямыхИКосвенныхЗатрат.Добавить(СчетаНалоговогоУчета.ВспомогательныеПроизводства);
СчетаПрямыхИКосвенныхЗатрат.Добавить(СчетаНалоговогоУчета.ОбщепроизводственныеРасходы);
СчетаПрямыхИКосвенныхЗатрат.Добавить(СчетаНалоговогоУчета.ОбщехозяйственныеРасходы);
СчетаПрямыхИКосвенныхЗатрат.Добавить(СчетаНалоговогоУчета.ОбслуживающиеПроизводства);
СчетаПрямыхИКосвенныхЗатрат.Добавить(СчетаНалоговогоУчета.РасходыНаПродажу);

#КонецЕсли