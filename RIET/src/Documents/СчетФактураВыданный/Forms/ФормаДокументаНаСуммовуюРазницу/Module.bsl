&НаКлиенте
Перем ПараметрыОбработчикаОжидания;

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Ключ.Пустая() Тогда
		ПодготовитьФормуНаСервере();
	КонецЕсли;
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ЗапуститьПроверкуКонтрагентовПриСозданииНаСервере();
	// } РГ-Софт Пахоменков А. 19.01.2015
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	//ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	ПодготовитьФормуНаСервере();
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ПроверкаКонтрагентов.ПриЧтенииНаСервере(ЭтаФорма);
	// } РГ-Софт Пахоменков А. 19.01.2015
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	Если ИспользованиеПроверкиВозможно Тогда
		ПроверкаКонтрагентов.СохранитьРезультатПроверкиКонтрагентовПослеЗаписи(ЭтаФорма);
	КонецЕсли;
	// } РГ-Софт Пахоменков А. 19.01.2015
	
	УстановитьЗаголовокФормы(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ПроверкаКонтрагентовКлиент.СохранитьРезультатПроверкиКонтрагентовПриЗакрытии(ЭтаФорма);
	// } РГ-Софт Пахоменков А. 19.01.2015

КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	// Вывести в заголовке формы вид операции и статус документа (новый, не проведен, проведен).
	ПолучитьЗаголовок();
	
	// Если открыли данную форму из формы документа, то там надо поменять текст
	Если  НЕ ВладелецФормы = Неопределено Тогда

		//изменила Наталья Петроченко 08.10.2012
		Если ТипЗнч(ВладелецФормы) = Тип("УправляемаяФорма") тогда

			// Обновляем информацию о счете-фактуре в открытых формах документов-оснований
			ДокументыОснования = Новый Массив;
			Для Каждого СтрокаТЧ Из Объект.ДокументыОснования Цикл
				ДокументыОснования.Добавить(СтрокаТЧ.ДокументОснование);
			КонецЦикла;
			ПараметрыЗаписи.Вставить("ДокументыОснования", ДокументыОснования);
			Оповестить("Запись_СчетФактураВыданный", ПараметрыЗаписи, Объект.Ссылка);
						
		иначе
			
			// Надо поменять текст про счет-фактуру в форме-владельце
			//-> RG-Soft VIVanov 01/08/12
			Если ТипЗнч(ВладелецФормы.Ссылка) = тип("ДокументСсылка.СчетКнигиПокупок") тогда
				ВладелецФормы.ЗаполнитьТекстПроСчетФактуру(Объект.Ссылка);
			//<-
			Иначе
				ВладелецФормы.ЗаполнитьТекстПроСчетФактуру();
			КонецЕсли;
			    		 			
		КонецЕсли;

	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	
	УправлениеФормой(ЭтаФорма);
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ЗапуститьПроверкуКонтрагентов();
	// } РГ-Софт Пахоменков А. 19.01.2015	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ПроверитьКонтрагентовПриНаступленииСобытия(ИмяСобытия, Параметр, Источник);
	// } РГ-Софт Пахоменков А. 19.01.2015
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ШАПКИ ФОРМЫ

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	ПараметрыДокумента = Новый Структура;
	ПараметрыДокумента.Вставить("Организация",        Объект.Организация);
	ПараметрыДокумента.Вставить("Контрагент",         Объект.Контрагент);
	ПараметрыДокумента.Вставить("ДоговорКонтрагента", Объект.ДоговорКонтрагента);
	
	НовыеПараметры = ПолучитьДанныеОрганизацияПриИзменении(ПараметрыДокумента);
	ЗаполнитьЗначенияСвойств(Объект, НовыеПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	ПараметрыДокумента = Новый Структура;
	ПараметрыДокумента.Вставить("Организация",        Объект.Организация);
	ПараметрыДокумента.Вставить("Контрагент" ,        Объект.Контрагент);
	ПараметрыДокумента.Вставить("ДоговорКонтрагента", Объект.ДоговорКонтрагента);
		
	НовыеПараметры = ПолучитьДанныеКонтрагентПриИзменении(ПараметрыДокумента);
	ЗаполнитьЗначенияСвойств(Объект, НовыеПараметры);
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ЗапуститьПроверкуКонтрагентов(Элемент);
	// } РГ-Софт Пахоменков А. 19.01.2015
	
КонецПроцедуры

&НаКлиенте
Процедура ДокументОснованиеПриИзменении(Элемент)
	
	Если ЗначениеЗаполнено(Объект.ДокументОснование) Тогда
		ЗаполнитьСчетФактуруНаСуммовуюРазницуСервер(Объект.ДокументОснование);	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СуммаПриИзменении(Элемент)
	
	Объект.СуммаНДС = ОбщегоНазначения.РассчитатьСуммуНДС(
		Объект.Сумма, Истина, Истина, УчетНДС.ПолучитьСтавкуНДС(Объект.СтавкаНДС));
	
КонецПроцедуры

&НаКлиенте
Процедура СуммовыеРазницыСтавкаНДСПриИзменении(Элемент)
	
	Объект.СуммаНДС = ОбщегоНазначения.РассчитатьСуммуНДС(
		Объект.Сумма, Истина, Истина, УчетНДС.ПолучитьСтавкуНДС(Объект.СтавкаНДС));
	
КонецПроцедуры

&НаКлиенте
Процедура КомментарийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ОбщегоНазначенияКлиент.ОткрытьФормуРедактированияКомментария(Элемент.ТекстРедактирования, Объект.Комментарий, Модифицированность);
	
КонецПроцедуры

&НаКлиенте
Процедура КодВидаОперацииНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ТекущийКод = Элемент.СписокВыбора.НайтиПоЗначению(Объект.КодВидаОперации);
	ВыбранныйКод = ВыбратьИзСписка(Элемент.СписокВыбора, Элемент, ТекущийКод);
	Если ВыбранныйКод <> Неопределено Тогда
		Объект.КодВидаОперации = ВыбранныйКод.Значение;
	КонецЕсли;

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

&НаКлиенте
Процедура ЗаполнитьПоДокументуОснованию(Команда)
	
	Если ЗначениеЗаполнено(Объект.ДокументОснование) Тогда
		ЗаполнитьСчетФактуруНаСуммовуюРазницуСервер(Объект.ДокументОснование);	
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ПодготовитьФормуНаСервере()

	МассивТипов	= Новый Массив;
	МассивТипов.Добавить(Тип("ДокументСсылка.РеализацияТоваровУслуг"));
	МассивТипов.Добавить(Тип("ДокументСсылка.ПередачаОС"));
	МассивТипов.Добавить(Тип("ДокументСсылка.ОтчетПринципалуОПродажах"));
	МассивТипов.Добавить(Тип("ДокументСсылка.ПлатежноеПоручениеВходящее"));
	
	Элементы.ДокументОснование.ОграничениеТипа = Новый ОписаниеТипов(МассивТипов);

	УчетНДС.ЗаполнитьСписокКодовВидовОпераций(Перечисления.ЧастиЖурналаУчетаСчетовФактур.ВыставленныеСчетаФактуры, ЭтаФорма.Элементы.КодВидаОперации.СписокВыбора);
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры 

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	Элементы	= Форма.Элементы;
	Объект		= Форма.Объект;
	
	Если Объект.СформированПриВводеНачальныхОстатковНДС Тогда
		Форма.ТолькоПросмотр	= Истина;
	КонецЕсли;
	
	УказанДокументОснование	= ЗначениеЗаполнено(Объект.ДокументОснование);
	
	Элементы.Организация.Доступность = НЕ УказанДокументОснование;
	Элементы.Контрагент.Доступность  = НЕ УказанДокументОснование;
	
	ИспользуетсяПостановлениеНДС1137 = ИспользуетсяПостановлениеНДС1137(Объект.Дата);
	Элементы.ГруппаВыставлениеСчетаФактуры.Доступность = ИспользуетсяПостановлениеНДС1137;
		
	УстановитьЗаголовокФормы(Форма);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьДоговорКонтрагента(ПараметрыДокумента)
	
	Если ОбщегоНазначения.ЗначениеНеЗаполнено(ПараметрыДокумента.Контрагент) Тогда 
		ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.ПустаяСсылка();
	Иначе
		ДоговорКонтрагента = УправлениеПользователями.ДоступныйДоговорКонтрагента(ПараметрыДокумента.Контрагент.ОсновнойДоговорКонтрагента);
	КонецЕсли;

	Если не ОбщегоНазначения.ЗначениеНеЗаполнено(ДоговорКонтрагента) тогда
		Если Не ЗначениеЗаполнено(ПараметрыДокумента.Организация) Тогда
			//Фильтр по организации не вклчается, договор подходит.	
		ИначеЕсли ПараметрыДокумента.Организация = ДоговорКонтрагента.Организация Тогда
			//принадлежит организации из документа, договор подходит.	
		Иначе
			//Договор не подходит. Очистим поле договора в документе.
			ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.ПустаяСсылка(); // Очистить старый договор
		КонецЕсли;
	КонецЕсли;

	Если НЕ ОбщегоНазначения.ЗначениеНеЗаполнено(ДоговорКонтрагента) Тогда
		ВидыДоговоров = Новый СписокЗначений;
		ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СПокупателем);
		ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомиссионером);
		//ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СПоставщиком);
		ВидыДоговоров.Добавить(Перечисления.ВидыДоговоровКонтрагентов.СКомитентом);
		ВидДоговора = ДоговорКонтрагента.ВидДоговора;
		Если ВидыДоговоров.НайтиПоЗначению(ВидДоговора) = Неопределено тогда
			//Договор не подходит. Очистим поле договора в документе.
			ДоговорКонтрагента = Справочники.ДоговорыКонтрагентов.ПустаяСсылка(); // Очистить старый договор
		КонецЕсли;
	КонецЕсли;
	Возврат ДоговорКонтрагента;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьДанныеОрганизацияПриИзменении(Знач ПараметрыДокумента)
	
	НовыеПараметры = Новый Структура;
	
	НовыйДоговор = ПолучитьДоговорКонтрагента(ПараметрыДокумента);
	НовыеПараметры.Вставить("ДоговорКонтрагента", НовыйДоговор);
	
	НовыеПараметры.Вставить("Сумма",    0);
	НовыеПараметры.Вставить("СуммаНДС", 0);
	НовыеПараметры.Вставить("ДокументОснование",                Неопределено);
	НовыеПараметры.Вставить("ДатаПлатежноРасчетногоДокумента",  '00010101');
	НовыеПараметры.Вставить("НомерПлатежноРасчетногоДокумента", "");
	
	Возврат НовыеПараметры;
		
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьДанныеКонтрагентПриИзменении(Знач ПараметрыДокумента)
	
	НовыеПараметры = Новый Структура;
	
	НовыйДоговор = ПолучитьДоговорКонтрагента(ПараметрыДокумента);
	НовыеПараметры.Вставить("ДоговорКонтрагента", НовыйДоговор);
	
	НовыеПараметры.Вставить("Сумма",    0);
	НовыеПараметры.Вставить("СуммаНДС", 0);
	НовыеПараметры.Вставить("ДокументОснование",                Неопределено);
	НовыеПараметры.Вставить("ДатаПлатежноРасчетногоДокумента",  '00010101');
	НовыеПараметры.Вставить("НомерПлатежноРасчетногоДокумента", "");
	
	Возврат НовыеПараметры;
		
КонецФункции

&НаСервере
Функция ЗаполнитьСчетФактуруНаСуммовуюРазницуСервер(Знач ДокументОснование)
	
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ОбработкаЗаполнения(ДокументОбъект.ДокументОснование);
	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");
    		
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьЗаголовокФормы(Форма)
	
	Объект = Форма.Объект;
	
	Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
		Форма.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Счет-фактура выданный %1 от %2 - суммовые разницы'"),
			Объект.Номер,
			Объект.Дата);
	Иначе
		Форма.Заголовок = НСтр("ru='Счет-фактура выданный (создание) - суммовые разницы'");
	КонецЕсли;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ИспользуетсяПостановлениеНДС1137(Период)

	Возврат (УчетНДС.ПолучитьВерсиюПостановления(Период) = 2);

КонецФункции

&НаСервере
Процедура ПолучитьЗаголовок()
	
	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	УстановитьЗаголовокФормыДокумента(, ДокументОбъект, ЭтаФорма);
    ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");

КонецПроцедуры

// Формирует и устанавливает текст заголовка формы документа
//
// Параметры:
//  СтрокаВидаОперации - строка вида операции документа, 
//  ДокументОбъект     - объект документа, 
//  ФормаДокумента     - форма документа.
//
Процедура УстановитьЗаголовокФормыДокумента(СтрокаВидаОперации = "", ДокументОбъект, ФормаДокумента) Экспорт

	ФормаДокумента.АвтоЗаголовок = Ложь; // заголовок будем писать сами
	
	Заголовок = "" + ДокументОбъект + ": ";
	
	Если НЕ ПустаяСтрока(СтрокаВидаОперации) Тогда
		Заголовок = Заголовок + СтрокаВидаОперации + ". ";
	КонецЕсли;
		
	Если ДокументОбъект.ЭтоНовый() Тогда  
		Заголовок = Заголовок + "Новый";
	Иначе
		Если ДокументОбъект.Проведен Тогда
			Заголовок = Заголовок + "Проведен";
		ИначеЕсли ДокументОбъект.Метаданные().Проведение = Метаданные.СвойстваОбъектов.Проведение.Разрешить Тогда
			Заголовок = Заголовок + "Не проведен";
		Иначе
			Заголовок = Заголовок + "Записан";
		КонецЕсли;
	КонецЕсли;
	
	ФормаДокумента.Заголовок = Заголовок;

КонецПроцедуры // УстановитьЗаголовокФормыДокумента()

&НаКлиенте
Процедура ПриОткрытии(Отказ)
		
	УправлениеФормой(ЭтаФорма);
	
	// { РГ-Софт Пахоменков А. 19.01.2015 ПроверкаКонтрагентов
	ПроверитьКонтрагентовПриОткрытии();
	// } РГ-Софт Пахоменков А. 19.01.2015
	
КонецПроцедуры

#Область ПроверкаКонтрагентов

&НаКлиенте
Процедура Подключаемый_ПоказатьПредложениеИспользоватьПроверкуКонтрагентов()
	
	ПроверкаКонтрагентовКлиент.ПредложитьВключитьПроверкуКонтрагентов(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьПроверкуКонтрагентов(ДополнительныеПараметры = Неопределено)
	
	Если ИспользованиеПроверкиВозможно Тогда
		
		ПараметрыФоновогоЗадания = ПроверкаКонтрагентовКлиент.ПараметрыФоновогоЗадания(ДополнительныеПараметры);
		ПроверитьКонтрагентовФоновоеЗадание(ПараметрыФоновогоЗадания);
		ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		
		// Прерываем предыдущую проверку
		ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", 1, Истина);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбработатьРезультатПроверкиКонтрагентов()
	
	ФоновоеЗаданиеЗавершилось = ПроверкаКонтрагентовВызовСервера.ПроверкаКонтрагентовЗавершилась(ИдентификаторЗаданияПроверкиКонтрагента);
	
	// Если есть незавершившиеся фоновые задания, то продолжаем ждать результат
	Если ФоновоеЗаданиеЗавершилось Тогда
		ОтобразитьРезультатПроверкиКонтрагента();
	Иначе
		ДлительныеОперацииКлиент.ОбновитьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", ПараметрыОбработчикаОжидания.ТекущийИнтервал, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОтобразитьРезультатПроверкиКонтрагента()
	ПроверкаКонтрагентов.ОтобразитьРезультатПроверкиКонтрагента(ЭтаФорма);
КонецПроцедуры

&НаСервере
Процедура ПроверитьКонтрагентовФоновоеЗадание(ДополнительныеПараметры = Неопределено)
	
	ПроверкаКонтрагентов.ПроверитьКонтрагентовВДокументеФоновоеЗадание(ЭтаФорма, ДополнительныеПараметры);
		
КонецПроцедуры

&НаСервере
Процедура ЗапуститьПроверкуКонтрагентовПриСозданииНаСервере()
	
	ИспользованиеПроверкиВозможно = ПроверкаКонтрагентовВызовСервера.ИспользованиеПроверкиВозможно();
	
	Если ИспользованиеПроверкиВозможно Тогда
		ПроверкаКонтрагентов.УправлениеФормойПриСозданииНаСервере(ЭтаФорма);
		ПроверитьКонтрагентовФоновоеЗадание();
	Иначе
		ПроверкаКонтрагентов.ПрорисоватьСостоянияКонтрагентовВДокументе(ЭтаФорма, Перечисления.СостоянияПроверкиКонтрагентов.ПроверкаНеИспользуется);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьКонтрагентовПриОткрытии()
	
	Если ИспользованиеПроверкиВозможно Тогда
		ДлительныеОперацииКлиент.ИнициализироватьПараметрыОбработчикаОжидания(ПараметрыОбработчикаОжидания);
		ПодключитьОбработчикОжидания("Подключаемый_ОбработатьРезультатПроверкиКонтрагентов", 0.1, Истина);
	Иначе
		ПодключитьОбработчикОжидания("Подключаемый_ПоказатьПредложениеИспользоватьПроверкуКонтрагентов", 0.1, Истина);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ТребуетсяПроверкаКонтрагентов(Источник) 
	Возврат ПроверкаКонтрагентов.ТребуетсяПроверкаКонтрагентов(ЭтаФорма, Источник);
КонецФункции

&НаКлиенте
Процедура ПроверитьКонтрагентовПриНаступленииСобытия(ИмяСобытия, Параметр, Источник)
	
	Если ПроверкаКонтрагентовКлиент.СобытиеТребуетПроверкиКонтрагента(ЭтаФорма, ИмяСобытия, Параметр, Источник)
		И ТребуетсяПроверкаКонтрагентов(Источник) Тогда
		
		ЗапуститьПроверкуКонтрагентов(Источник);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти