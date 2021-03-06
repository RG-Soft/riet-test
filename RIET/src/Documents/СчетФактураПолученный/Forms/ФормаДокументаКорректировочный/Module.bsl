&НаКлиенте
Перем ПараметрыОбработчикаОжидания;

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.Печать
	УправлениеПечатью.ПриСозданииНаСервере(ЭтаФорма, Элементы.ГруппаПечать);
	// Конец СтандартныеПодсистемы.Печать
	
	// ДополнительныеОтчетыИОбработки
	ДополнительныеОтчетыИОбработки.ПриСозданииНаСервере(ЭтаФорма, ДополнительныеОтчетыИОбработкиКлиентСервер.ТипФормыОбъекта());
	// Конец ДополнительныеОтчетыИОбработки
	
	Если Параметры.Ключ.Пустая() Тогда
		ПодготовитьФормуНаСервере();
		ЗаполнитьЗначенияСвойств(Объект, Параметры.ЗначенияЗаполнения);
	КонецЕсли;
	
	// Заполнение группы информационных ссылок
	ИнформационныйЦентрСервер.ВывестиКонтекстныеСсылки(ЭтаФорма, Элементы.ИнформационныеСсылки);

	ЗапуститьПроверкуКонтрагентовПриСозданииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ИсточникВыбора.ИмяФормы = "Документ.СчетФактураПолученный.Форма.ФормаДокументыОснования" Тогда
		Модифицированность	= Истина;
		ОбработкаВыбораПодборНаСервере(ВыбранноеЗначение);
	ИначеЕсли ТипЗнч(ВыбранноеЗначение) = Тип("Структура") Тогда
		Модифицированность	= Истина;
		ЗаполнитьЗначенияСвойств(Объект, ВыбранноеЗначение);
	КонецЕсли;
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОбновитьСостояниеЭД" Тогда
		УстановитьТекстСостоянияЭДНаСервере();
	ИначеЕсли ИмяСобытия = "ОбновитьДокументИБПослеЗаполнения" И Параметр.Найти(Объект.Ссылка) <> Неопределено Тогда
		Прочитать();
	Иначе
		ОбщегоНазначенияБПКлиент.ОбработкаОповещенияФормыДокумента(ЭтаФорма, Объект.Ссылка, ИмяСобытия, Параметр, Источник);
	КонецЕсли;
	
	ПроверитьКонтрагентовПриНаступленииСобытия(ИмяСобытия, Параметр, Источник);
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	//ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтаФорма, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	ПодготовитьФормуНаСервере();
	
	ПроверкаКонтрагентов.ПриЧтенииНаСервере(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.РежимЗаписи = ПредопределенноеЗначение("РежимЗаписиДокумента.Проведение") Тогда
		КлючеваяОперация = "ПроведениеСчетФактураПолученныйКорректировочный";
		ОценкаПроизводительностиКлиентСервер.НачатьЗамерВремени(КлючеваяОперация);
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	Если ИспользованиеПроверкиВозможно Тогда
		ПроверкаКонтрагентов.СохранитьРезультатПроверкиКонтрагентовПослеЗаписи(ЭтотОбъект);
	КонецЕсли;
	
	УстановитьТекстСостоянияЭДНаСервере();
	
	ПредставлениеДокумента = Документы.СчетФактураПолученный.ПолучитьПредставлениеДокумента(Объект.Ссылка, Объект.ВидСчетаФактуры);
	УстановитьЗаголовокФормы(ЭтаФорма, ПредставлениеДокумента);
	
	УчетНДСКлиентСервер.ДополнитьПараметрыСобытияЗаписьСчетаФактуры(ПараметрыЗаписи);
	ПараметрыЗаписи.ДокументыОснования = ОбщегоНазначения.ВыгрузитьКолонку(ТекущийОбъект.ДокументыОснования, "ДокументОснование", Истина);
	ПараметрыЗаписи.РеквизитыСФ        = УчетНДСВызовСервера.РеквизитыДляНадписиОСчетеФактуреПолученном(ТекущийОбъект.Ссылка);
	
	УстановитьСостояниеДокумента();
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	УчетНДСКлиентСервер.ДополнитьПараметрыСобытияЗаписьСчетаФактуры(ПараметрыЗаписи); // На 8.2 в web-клиенте ПараметрыЗаписи могут быть не инициализированы
	
	// Обновляем информацию о счете-фактуре в открытых формах документов-оснований
	Оповестить("Запись_СчетФактураПолученныйКорректировочный", ПараметрыЗаписи, Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	ПроверкаКонтрагентовКлиент.СохранитьРезультатПроверкиКонтрагентовПриЗакрытии(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ПроверитьКонтрагентовПриОткрытии();

КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ШАПКИ ФОРМЫ

&НаКлиенте
Процедура ДатаПолученияПриИзменении(Элемент)

	Если Объект.Исправление Тогда
		Если Объект.Дата < Объект.ДатаИсправления Тогда 
			Объект.Дата = Объект.ДатаИсправления;
		КонецЕсли;
	Иначе
		Если Объект.Дата < Объект.ДатаВходящегоДокумента Тогда 
			Объект.Дата = Объект.ДатаВходящегоДокумента;
		КонецЕсли;
	КонецЕсли;

	ПриИзмененииДаты();
		
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)

	Если ЗначениеЗаполнено(Объект.Организация) Тогда
		ОрганизацияПриИзмененииНаСервере();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)

	КонтрагентПриИзмененииНаСервере();
	ЗапуститьПроверкуКонтрагентов(Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеКППКонтрагентаНажатие(Элемент, СтандартнаяОбработка)

	СтандартнаяОбработка = Ложь;
	
	СтруктураПараметров	= Новый Структура("Контрагент, КППКонтрагента, РольКонтрагента");
	СтруктураПараметров.РольКонтрагента	= "Поставщик";
	ЗаполнитьЗначенияСвойств(СтруктураПараметров, Объект);
	ОткрытьФорму("ОбщаяФорма.ФормаВыбораКПП", СтруктураПараметров, ЭтаФорма)

КонецПроцедуры

&НаКлиенте
Процедура КодВидаОперацииНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ТекущийКод = Элемент.СписокВыбора.НайтиПоЗначению(Объект.КодВидаОперации);
	ОповещениеВыбора = Новый ОписаниеОповещения("ВыборИзСпискаЗавершение", ЭтотОбъект);
	ПоказатьВыборИзСписка(ОповещениеВыбора, Элемент.СписокВыбора, Элемент, ТекущийКод);
	
КонецПроцедуры

&НаКлиенте
Процедура СостояниеЭДНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЭлектронныеДокументыКлиент.ОткрытьДеревоЭД(Объект.Ссылка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПродавецПриИзменении(Элемент)
	ЗапуститьПроверкуКонтрагентов(Элемент);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ БСП

// СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки

&НаСервере
Процедура ДополнительныеОтчетыИОбработкиВыполнитьНазначаемуюКомандуНаСервере(ИмяЭлемента, РезультатВыполнения)
	
	ДополнительныеОтчетыИОбработки.ВыполнитьНазначаемуюКомандуНаСервере(ЭтаФорма, ИмяЭлемента, РезультатВыполнения);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ВыполнитьНазначаемуюКоманду(Команда)
	
	Если НЕ ДополнительныеОтчетыИОбработкиКлиент.ВыполнитьНазначаемуюКомандуНаКлиенте(ЭтаФорма, Команда.Имя) Тогда
		РезультатВыполнения = Неопределено;
		ДополнительныеОтчетыИОбработкиВыполнитьНазначаемуюКомандуНаСервере(Команда.Имя, РезультатВыполнения);
		ДополнительныеОтчетыИОбработкиКлиент.ПоказатьРезультатВыполненияКоманды(ЭтаФорма, РезультатВыполнения);
	КонецЕсли;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.ДополнительныеОтчетыИОбработки

// СтандартныеПодсистемы.Печать
&НаКлиенте
Процедура Подключаемый_ВыполнитьКомандуПечати(Команда)
	
	УправлениеПечатьюКлиент.ВыполнитьПодключаемуюКомандуПечати(Команда, ЭтаФорма, Объект);
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.Печать

////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

&НаСервере
Процедура ПодготовитьФормуНаСервере()
	
	УстановитьФункциональныеОпцииФормы();
	
	УстановитьСостояниеДокумента();
	
	УстановитьТекстСостоянияЭДНаСервере();
	
	ЗагрузитьСписокИсходныхСчетовФактур();
	
	Элементы.ГруппаСостояниеЭД.Видимость = ПолучитьФункциональнуюОпцию("ИспользоватьОбменЭД");
	
	ТекущаяДатаДокумента	= Объект.Дата;
	
	ВалютаРегламентированногоУчета	= ОбщегоНазначенияБПВызовСервераПовтИсп.ПолучитьВалютуРегламентированногоУчета();
	
	ПредставлениеДокумента = Документы.СчетФактураПолученный.ПолучитьПредставлениеДокумента(Объект.Ссылка, Объект.ВидСчетаФактуры);
	УстановитьЗаголовокФормы(ЭтаФорма, ПредставлениеДокумента);
	
	УчетНДС.ЗаполнитьСписокКодовВидовОпераций(Перечисления.ЧастиЖурналаУчетаСчетовФактур.ПолученныеСчетаФактуры, ЭтаФорма.Элементы.КодВидаОперации.СписокВыбора);
	
	Если ЗначениеЗаполнено(Объект.Контрагент) Тогда
		КППКонтрагента			= ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "КПП");
	Иначе
		КППКонтрагента			= "";
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.ДоговорКонтрагента) Тогда
		ВидДоговораКонтрагента	= ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ДоговорКонтрагента, "ВидДоговора");
	Иначе
		ВидДоговораКонтрагента	= Перечисления.ВидыДоговоровКонтрагентов.ПустаяСсылка();
	КонецЕсли;
	
	Для каждого СтрокаОснования Из Объект.ДокументыОснования Цикл
		Если ЗначениеЗаполнено(СтрокаОснования.ДокументОснование) Тогда
			НаОснованииОтчетаКомитенту	= (ТипЗнч(СтрокаОснования.ДокументОснование) = Тип("ДокументСсылка.ОтчетКомитентуОПродажах"));
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	УстановитьВидимость();
	
	ДекорацияОрганизация = ВернутьСтр("ru = 'Организация:'");
	ДекорацияОтветственный = ВернутьСтр("ru = 'Ответственный:'");
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьСостояниеДокумента()
	
	СостояниеДокумента = ОбщегоНазначенияБП.СостояниеДокумента(Объект);
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьСписокИсходныхСчетовФактур()
	
	ИсходныеСчетаФактуры.Очистить();
		
	Для Каждого Основание Из Объект.ДокументыОснования Цикл
		
		СчетФактура = ИсходныеСчетаФактуры.Добавить();
		ЗаполнитьЗначенияСвойств(СчетФактура, Основание); 
		
		РеквизитыИсходногоСчетаФактуры = Документы.СчетФактураПолученный.ПолучитьРеквизитыИсходногоСчетаФактурыДляКорректировки(Основание.ДокументОснование, Объект.Ссылка, Истина);
		
		Если РеквизитыИсходногоСчетаФактуры <> Неопределено Тогда 
			ЗаполнитьЗначенияСвойств(СчетФактура, РеквизитыИсходногоСчетаФактуры); 
		Иначе
			СчетФактура.СчетФактураКраткоеПредставление = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = '%1 от %2'"), ?(Основание.УчитыватьИсправлениеИсходногодокумента,
				Основание.НомерИсходногоДокумента + " (испр. " + Основание.НомерИсправленияИсходногоДокумента +")", Основание.НомерИсходногоДокумента), Формат(Основание.ДатаИсходногоДокумента, "ДЛФ=Д"));
		КонецЕсли;
			
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура УстановитьФункциональныеОпцииФормы()
	
	ОбщегоНазначенияБПКлиентСервер.УстановитьПараметрыФункциональныхОпцийФормыДокумента(ЭтаФорма);
	
	ИспользуетсяПостановлениеНДС1137	= УчетНДСПереопределяемый.ИспользуетсяПостановлениеНДС1137(Объект.Дата);
	
	ОтражатьСуммыВЖурнале = Объект.Дата >= '20150101' И (ПолучитьФункциональнуюОпцию("ОсуществляетсяЗакупкаТоваровУслугДляКомитентов")
		ИЛИ ПолучитьФункциональнуюОпцию("ОсуществляетсяРеализацияТоваровУслугКомитентов"));
	
КонецПроцедуры

&НаСервере
Процедура УстановитьВидимость()

	Элементы.ГруппаПродавец.Видимость	= ИспользуетсяПостановлениеНДС1137
		И ВидДоговораКонтрагента = Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку;
	
	Элементы.ПредставлениеКППКонтрагента.Видимость	= ИспользуетсяПостановлениеНДС1137 И
		ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "ЮридическоеФизическоеЛицо") <> Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо;
		
	Элементы.ГруппаИтоги.Видимость	= ИспользуетсяПостановлениеНДС1137;

КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(Форма)
	
	Элементы	= Форма.Элементы;
	Объект		= Форма.Объект;
	
	Если Объект.СформированПриВводеНачальныхОстатковНДС Тогда
		Форма.ТолькоПросмотр	= Истина;
	КонецЕсли;
	
	Элементы.Контрагент.ТолькоПросмотр			= Форма.НаОснованииОтчетаКомитенту;
	Элементы.Продавец.Доступность				= ЗначениеЗаполнено(Объект.ДоговорКонтрагента);
	
	Элементы.НомерИсправленияСистемный.Доступность	= Объект.Исправление;
	Элементы.ДатаИсправлениясистемная.Доступность	= Объект.Исправление;
	
	Элементы.ГруппаВидаОперации.Видимость 		= Форма.ИспользуетсяПостановлениеНДС1137;
	
	Если Форма.ИспользуетсяПостановлениеНДС1137 И Объект.Исправление Тогда
		Элементы.ГруппаТекущиеНомераИДаты.ТекущаяСтраница 	= Элементы.ГруппаИсправляемый;  
		Элементы.ГруппаРеквизитыИсправления.Видимость 		= Истина;  
		Форма.НадписьСчетФактура = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = '%1 от %2'"),
			Объект.НомерВходящегоДокумента,Формат(Объект.ДатаВходящегоДокумента,"ДЛФ=Д"));
	Иначе
		Элементы.ГруппаТекущиеНомераИДаты.ТекущаяСтраница 	= Элементы.ГруппаТекущий;
		Элементы.ГруппаРеквизитыИсправления.Видимость 		= Ложь;  
	КонецЕсли;
	
	КоличествоОснований = Объект.ДокументыОснования.Количество();
	
	Если КоличествоОснований = 0 Тогда
		Форма.НадписьВыбор = ВернутьСтр("ru = 'Выбор'");
		Элементы.СтраницыОснования.ТекущаяСтраница 	= Элементы.СтраницаВыбора;
	ИначеЕсли КоличествоОснований = 1 Тогда 
		Элементы.СтраницыОснования.ТекущаяСтраница 	= Элементы.СтраницаОснования;
	Иначе 		
		
		Элементы.СтраницыОснования.ТекущаяСтраница 	= Элементы.СтраницаОснований;
		
		ФормСтрока 		= "Л = ru_RU; ЧДЦ=0";
		ПарПредмета		= "документ,документа,документов,м,,,,0";
		ПрописьЧисла 	= ЧислоПрописью(КоличествоОснований, ФормСтрока, ПарПредмета);
		ИндексПредмета 	= СтрНайти(ПрописьЧисла, "док");
		ТекстДокументы 	= Строка(КоличествоОснований) + " " + Сред(ПрописьЧисла, ИндексПредмета, СтрДлина(ПрописьЧисла)- ИндексПредмета - 3);
		ТекстНадписи 	= СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = '%1 (%2 и еще %3)'"), ТекстДокументы, Строка(Объект.ДокументыОснования[0].ДокументОснование), КоличествоОснований-1);	
		
		Форма.НадписьДокументыОснования	= ТекстНадписи;
		
	КонецЕсли;
	
	ТекущийКод = Элементы.КодВидаОперации.СписокВыбора.НайтиПоЗначению(Объект.КодВидаОперации);
	Если ТекущийКод <> Неопределено Тогда 
		Форма.НадписьВидОперации = Сред(ТекущийКод.Представление, 5);
	Иначе
		Форма.НадписьВидОперации = "";
	КонецЕсли;

	КоличествоКорректируемыхСчетовФактур = Форма.ИсходныеСчетаФактуры.Количество();
	
	Если КоличествоКорректируемыхСчетовФактур <> 0 Тогда 
		ТекстКорректируемыйСчетФактура = Форма.ИсходныеСчетаФактуры[0].СчетФактураКраткоеПредставление;
	Иначе
		ТекстКорректируемыйСчетФактура = "";
	КонецЕсли;
	
	Если КоличествоКорректируемыхСчетовФактур > 1 Тогда
		Элементы.ДекорацияКСчетуФактуре.Заголовок 	=  ВернутьСтр("ru = 'К счетам-фактурам:'");
		Форма.НадписьСчетФактураКорректируемый		= СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ВернутьСтр("ru = '%1 и еще %2 с/ф'"), 
		ТекстКорректируемыйСчетФактура, КоличествоКорректируемыхСчетовФактур-1);
	Иначе
		Элементы.ДекорацияКСчетуФактуре.Заголовок 	=  ВернутьСтр("ru = 'К счету-фактуре:'");
		Форма.НадписьСчетФактураКорректируемый 		= ТекстКорректируемыйСчетФактура;
	КонецЕсли;

	Если Форма.ОтражатьСуммыВЖурнале Тогда
		Элементы.СтраницыКомиссия.ТекущаяСтраница = Элементы.ГруппаЕстьКомиссия;
	Иначе
		Элементы.СтраницыКомиссия.ТекущаяСтраница = Элементы.ГруппаНетКомиссии;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Объект.Контрагент) Тогда
		Если НЕ ПустаяСтрока(Объект.КППКонтрагента) Тогда
			ЗначениеКППКонтрагента	= Объект.КППКонтрагента;
		Иначе
			ЗначениеКППКонтрагента	= Форма.КППКонтрагента;
		КонецЕсли;
		
		Форма.ПредставлениеКППКонтрагента	= СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			ВернутьСтр("ru = 'КПП %1'"), ?(ПустаяСтрока(ЗначениеКППКонтрагента), "<не задан>", ЗначениеКППКонтрагента));
	Иначе
		Форма.ПредставлениеКППКонтрагента	= "";
	КонецЕсли;
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура УстановитьЗаголовокФормы(Форма, ПредставлениеДокумента)
	
	Форма.Заголовок = ПредставлениеДокумента.СчетФактураПредставление;
	
КонецПроцедуры

&НаСервере
Процедура ДатаПриИзмененииНаСервере()
	
	УстановитьФункциональныеОпцииФормы();
	
	УстановитьКодВидаОперацииНаСервере();

	Если НЕ ИспользуетсяПостановлениеНДС1137 Тогда
		
		Объект.Продавец	= Неопределено;
		
	КонецЕсли;
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ОрганизацияПриИзмененииНаСервере()

	УстановитьФункциональныеОпцииФормы();
	
	КонтрагентПриИзмененииНаСервере();
	
	УстановитьВидимость();
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура КонтрагентПриИзмененииНаСервере()

	КонтрагентОбработатьИзменениеНаСервере();
	
	УстановитьВидимость();
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура КонтрагентОбработатьИзменениеНаСервере()

	Объект.ДокументОснование	= Неопределено;
	Объект.ДоговорКонтрагента	= Неопределено;
	ВидДоговораКонтрагента 		= Неопределено;
	Объект.СуммаДокумента 		= 0;
	Объект.СуммаНДСДокумента	= 0;
	Объект.ДокументыОснования.Очистить();
	
	КППКонтрагента	= ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.Контрагент, "КПП");
	Если Объект.ДокументыОснования.Количество() > 0 Тогда
		Объект.КППКонтрагента	= УчетНДСБП.ПолучитьКПППодразделенияКонтрагента(Объект.ДокументыОснования[0].ДокументОснование, "Грузоотправитель");
	Иначе
		Объект.КППКонтрагента	= "";
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура УстановитьКодВидаОперацииНаСервере()
	
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("Дата",						Объект.Дата);
	СтруктураПараметров.Вставить("ВидСчетаФактуры",				Объект.ВидСчетаФактуры);
	СтруктураПараметров.Вставить("Исправление",					Объект.Исправление);
	СтруктураПараметров.Вставить("КодВидаОперацииОснования",	Неопределено);
	СтруктураПараметров.Вставить("ВидДоговора",					ВидДоговораКонтрагента);
	СтруктураПараметров.Вставить("ДокументыОснования",			Объект.ДокументыОснования.Выгрузить(,"ДокументОснование"));
	СтруктураПараметров.Вставить("СчетФактураБезНДС",			Объект.СчетФактураБезНДС);
	
	Объект.КодВидаОперации	= Документы.СчетФактураПолученный.ПолучитьКодВидаОперации(СтруктураПараметров);
	
КонецПроцедуры

&НаСервере
Процедура ДокументыОснованияДокументОснованиеПриИзмененииНаСервере()

	ДокументОбъект = РеквизитФормыВЗначение("Объект");
	ДокументОбъект.ОпределениеПараметровСчетаФактуры();
	ЗначениеВРеквизитФормы(ДокументОбъект, "Объект");
	ЗагрузитьСписокИсходныхСчетовФактур();
	ВидДоговораКонтрагента	= ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Объект.ДоговорКонтрагента, "ВидДоговора");
	Если ВидДоговораКонтрагента <> Перечисления.ВидыДоговоровКонтрагентов.СКомиссионеромНаЗакупку Тогда
		Объект.Продавец	= Неопределено;
	КонецЕсли;

	УстановитьВидимость();
	
	УправлениеФормой(ЭтаФорма);

КонецПроцедуры

&НаСервере
Процедура УстановитьТекстСостоянияЭДНаСервере()
	
	ТекстСостоянияЭД = ЭлектронныеДокументыКлиентСервер.ПолучитьТекстСостоянияЭД(Объект.Ссылка, ЭтаФорма);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_НажатиеНаИнформационнуюСсылку(Элемент)
	
	ИнформационныйЦентрКлиент.НажатиеНаИнформационнуюСсылку(ЭтаФорма, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_НажатиеНаСсылкуВсеИнформационныеСсылки(Элемент)
	
	ИнформационныйЦентрКлиент.НажатиеНаСсылкуВсеИнформационныеСсылки(ЭтаФорма.ИмяФормы);
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьСчетФактураНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПоказатьЗначение( , Объект.ИсправляемыйСчетФактура);
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьСчетФактураКорректируемыйНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	Если ЭтаФорма.ИсходныеСчетаФактуры.Количество() = 1 Тогда
		ПоказатьЗначение( , ИсходныеСчетаФактуры[0].СчетФактура);
	Иначе
		
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("СчетаФактуры", ИсходныеСчетаФактуры);
			
		ОткрытьФорму("ОбщаяФорма.ФормаПросмотраСчетовФактурОснований", ПараметрыФормы, ЭтаФорма);
		
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура НадписьДокументыОснованияНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьОснование();
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьСтруктуруПараметровФормы()
	
	СтруктураПараметров = Новый Структура();
	ЗначенияЗаполнения 	= Новый Структура();
	ЗначениеОтбора 		= Новый Структура();
	
	Если Объект.ДокументыОснования.Количество() > 0 Тогда 
		ЗначенияЗаполнения.Вставить("СписокДокументовОснований", Новый СписокЗначений);
		Для Каждого СтрокаТаблицы Из Объект.ДокументыОснования Цикл
			ЗначенияЗаполнения.СписокДокументовОснований.Добавить(СтрокаТаблицы.ДокументОснование)
		КонецЦикла;
	КонецЕсли;
	
	ЗначенияЗаполнения.Вставить("ТипСчетаФактуры", "Полученный");
	ЗначенияЗаполнения.Вставить("ВидСчетаФактуры", Объект.ВидСчетаФактуры);
	ЗначенияЗаполнения.Вставить("Исправление", Объект.Исправление);
	ЗначенияЗаполнения.Вставить("СчетФактура", Объект.Ссылка);
	
	ЗначениеОтбора.Вставить("Организация", Объект.Организация);
	ЗначениеОтбора.Вставить("Контрагент", Объект.Контрагент);
	ЗначениеОтбора.Вставить("Договор", Объект.ДоговорКонтрагента);
	ЗначениеОтбора.Вставить("Валюта", Объект.ВалютаДокумента);
	
	СтруктураПараметров.Вставить("ЗначенияЗаполнения", ЗначенияЗаполнения); 
	СтруктураПараметров.Вставить("Отбор", ЗначениеОтбора);
		
	Возврат СтруктураПараметров;
	
КонецФункции

&НаКлиенте
Процедура ВыбратьОснование()
	
	ЕстьОшибкиЗаполнения = Ложь;
	
	Если Не ЗначениеЗаполнено(Объект.Организация) Тогда 
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
			"Поле", "Заполнение", ВернутьСтр("ru = 'Организация'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Организация", "Объект" , ЕстьОшибкиЗаполнения);
	КонецЕсли;
		
	Если Не ЗначениеЗаполнено(Объект.Контрагент) Тогда 
		ТекстСообщения = ОбщегоНазначенияКлиентСервер.ТекстОшибкиЗаполнения(
			"Поле", "Заполнение", ВернутьСтр("ru = 'Контрагент'"));
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Контрагент", "Объект" , ЕстьОшибкиЗаполнения);
	КонецЕсли;
	
	Если ЕстьОшибкиЗаполнения Тогда
		Возврат;
	КонецЕсли;
	
	ПараметрыФормы = ПолучитьСтруктуруПараметровФормы();
		
	ОткрытьФорму("Документ.СчетФактураПолученный.Форма.ФормаДокументыОснования",
			ПараметрыФормы,
			ЭтаФорма);
					
КонецПроцедуры

&НаСервере
Процедура ОбработкаВыбораПодборНаСервере(ВыбранноеЗначение)

	Объект.ДокументыОснования.Очистить();
	Если ВыбранноеЗначение.Количество() = 0 Тогда 
		Объект.СуммаДокумента 		= 0;
		Объект.СуммаНДСДокумента	= 0;
	Иначе
		Для Каждого СтрокаСписка Из ВыбранноеЗначение Цикл
			Если СтрокаСписка.Значение.Пустая() Тогда
				Продолжить;
			КонецЕсли; 
			СтрокаТаблицы = Объект.ДокументыОснования.Добавить();
			СтрокаТаблицы.ДокументОснование = СтрокаСписка.Значение;
		КонецЦикла;
	КонецЕсли;
	
	ДокументыОснованияДокументОснованиеПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	ПолучитьРежимЗаписи();
	Если ЭтаФорма.Записать(Новый Структура("РежимЗаписи", РежимЗаписи)) Тогда 
		ЭтаФорма.Закрыть();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура КодВидаОперацииПриИзменении(Элемент)
	
	ТекущийКод = Элемент.СписокВыбора.НайтиПоЗначению(Объект.КодВидаОперации);
	Если ТекущийКод <> Неопределено Тогда
		НадписьВидОперации = Сред(ТекущийКод.Представление, 5);
	Иначе
		НадписьВидОперации = "";
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьРежимЗаписи()
	
	Проводить = Истина;
	
	Для Каждого Стр из Объект.ДокументыОснования Цикл
		Если Стр.ДокументОснование <> Неопределено
			И НЕ ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Стр.ДокументОснование, "Проведен") Тогда
			Проводить = Ложь;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если Проводить Тогда
		РежимЗаписи = РежимЗаписиДокумента.Проведение;
	Иначе
		РежимЗаписи = РежимЗаписиДокумента.Запись;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура ДатаПриИзменении(Элемент)
	
	Объект.Дата = Объект.ДатаВходящегоДокумента;
	ПриИзмененииДаты();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриИзмененииДаты()
	
	Если НачалоДня(Объект.Дата) = НачалоДня(ТекущаяДатаДокумента) Тогда
		// Изменение времени не влияет на поведение документа.
		ТекущаяДатаДокумента = Объект.Дата;
		Возврат;
	КонецЕсли;
	
	ЗапуститьПроверкуКонтрагентов();

	// Общие проверки условий по датам.
	ТребуетсяВызовСервера = ОбщегоНазначенияБПКлиент.ТребуетсяВызовСервераПриИзмененииДатыДокумента(Объект.Дата, 
		ТекущаяДатаДокумента);
		
	// Если определили, что изменение даты может повлиять на какие-либо параметры, 
	// то передаем обработку на сервер.
	Если ТребуетсяВызовСервера Тогда
		ДатаПриИзмененииНаСервере();
	КонецЕсли;
	
	// Запомним новую дату документа.
	ТекущаяДатаДокумента = Объект.Дата;
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьИзменитьНажатие(Элемент)
	
	ВыбратьОснование();
	
КонецПроцедуры

&НаКлиенте
Процедура ДатаИсправленияПриИзменении(Элемент)
	
	Объект.Дата = Объект.ДатаИсправления;
	ПриИзмененииДаты();

КонецПроцедуры

&НаКлиенте
Процедура НадписьВыборНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ВыбратьОснование();
	
КонецПроцедуры

&НаКлиенте
Процедура ВыборИзСпискаЗавершение(ВыбранныйКод, ДополнительныеПараметры) Экспорт

	Если ВыбранныйКод <> Неопределено Тогда
		Модифицированность = Истина;
		Объект.КодВидаОперации = ВыбранныйКод.Значение;
		НадписьВидОперации = Сред(ВыбранныйКод.Представление, 5);
	КонецЕсли;

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
	ПроверкаКонтрагентов.ОтобразитьРезультатПроверкиКонтрагента(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ПроверитьКонтрагентовФоновоеЗадание(ДополнительныеПараметры = Неопределено)
	
	ПроверкаКонтрагентов.ПроверитьКонтрагентовВДокументеФоновоеЗадание(ЭтотОбъект, ДополнительныеПараметры);
		
КонецПроцедуры

&НаСервере
Процедура ЗапуститьПроверкуКонтрагентовПриСозданииНаСервере()
	
	ИспользованиеПроверкиВозможно = ПроверкаКонтрагентовВызовСервера.ИспользованиеПроверкиВозможно();
	
	Если ИспользованиеПроверкиВозможно Тогда
		ПроверкаКонтрагентов.УправлениеФормойПриСозданииНаСервере(ЭтотОбъект);
		ПроверитьКонтрагентовФоновоеЗадание();
	Иначе
		ПроверкаКонтрагентов.ПрорисоватьСостоянияКонтрагентовВДокументе(ЭтотОбъект, Перечисления.СостоянияПроверкиКонтрагентов.ПроверкаНеИспользуется);
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
	Возврат ПроверкаКонтрагентов.ТребуетсяПроверкаКонтрагентов(ЭтотОбъект, Источник);
КонецФункции

&НаКлиенте
Процедура ПроверитьКонтрагентовПриНаступленииСобытия(ИмяСобытия, Параметр, Источник)
	
	Если ПроверкаКонтрагентовКлиент.СобытиеТребуетПроверкиКонтрагента(ЭтотОбъект, ИмяСобытия, Параметр, Источник)
		И ТребуетсяПроверкаКонтрагентов(Источник) Тогда
		
		ЗапуститьПроверкуКонтрагентов(Источник);
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти