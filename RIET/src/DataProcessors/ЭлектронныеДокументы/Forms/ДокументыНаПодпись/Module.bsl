#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ИспользуетсяОбменСБанками()
	
	Возврат ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьЗначениеФункциональнойОпции("ИспользоватьОбменЭДСБанками");
	
КонецФункции

&НаСервере
Процедура ЗаполнитьСписокСертификатовИДокументов(МассивОтпечатковСертификатов)
	
	ТаблицаДоступныхСертификатов = ЭлектронныеДокументыСлужебный.ТаблицаДоступныхДляПодписиСертификатов(
																			МассивОтпечатковСертификатов);
	ЗаполнитьСводнуюТаблицу(ТаблицаДоступныхСертификатов);
	ЗаполнитьСписокСертификатов(ТаблицаДоступныхСертификатов);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокСертификатов(ТаблицаДоступныхСертификатов)
	
	ТаблицаСертификатов.Очистить();
	Для Каждого ТекСтрока Из ТаблицаДоступныхСертификатов Цикл
		СтрокаТаблицы = ТаблицаСертификатов.Добавить();
		СтрокаТаблицы.Сертификат = ТекСтрока.Ссылка;
		СтрокаТаблицы.Отпечаток = ТекСтрока.Отпечаток;
		СтрокаТаблицы.ПарольПользователя = ТекСтрока.ПарольПользователя;
		ПараметрыОтбора = Новый Структура("Сертификат", ТекСтрока.Ссылка);
		СтрокаТаблицы.КоличествоДокументов = СводнаяТаблица.НайтиСтроки(ПараметрыОтбора).Количество();
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСводнуюТаблицу(ТаблицаДоступныхСертификатов)
	
	ЗапросПоДокументам = Новый Запрос;
	
	СтруктураДопОтбора = Новый Структура;
	Если ЗначениеЗаполнено(Контрагент) Тогда 
		СтруктураДопОтбора.Вставить("Контрагент", Контрагент);
		ЗапросПоДокументам.УстановитьПараметр("Контрагент", Контрагент);
	КонецЕсли;
	Если ЗначениеЗаполнено(ВидЭД) Тогда 
		СтруктураДопОтбора.Вставить("ВидЭД", ВидЭД);
		ЗапросПоДокументам.УстановитьПараметр("ВидЭД", ВидЭД);
	КонецЕсли;
	Если ЗначениеЗаполнено(НаправлениеЭД) Тогда 
		СтруктураДопОтбора.Вставить("НаправлениеЭД", НаправлениеЭД);
		ЗапросПоДокументам.УстановитьПараметр("НаправлениеЭД", НаправлениеЭД);
	КонецЕсли;
	
	ЗапросПоДокументам.Текст = ЭлектронныеДокументы.ПолучитьТекстЗапросаЭлектронныхДокументовНаПодписи(Ложь, СтруктураДопОтбора);
	ЗапросПоДокументам.УстановитьПараметр("ТекущийПользователь", Пользователи.ТекущийПользователь());
	СвойстваНеуказанногоПользователя = ПользователиСлужебный.СвойстваНеуказанногоПользователя();
	ЗапросПоДокументам.УстановитьПараметр("ПользовательНеУказан", СвойстваНеуказанногоПользователя.Ссылка);
	Таблица = ЗапросПоДокументам.Выполнить().Выгрузить();
	
	ЗначениеВРеквизитФормы(Таблица, "СводнаяТаблица");
	
КонецПроцедуры

&НаКлиенте
Процедура ПерезаполнитьТаблицы()
	
	Оповещение = Новый ОписаниеОповещения("ПослеПолученияОтпечатковПерезаполнитьТаблицы", ЭтотОбъект);
	ЭлектроннаяПодписьКлиент.ПолучитьОтпечаткиСертификатов(Оповещение, Истина, Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеПолученияОтпечатковПерезаполнитьТаблицы(Отпечатки, ДополнительныеПараметры = Неопределено) Экспорт
	
	МассивОтпечатковСертификатов = Новый Массив;
	Для Каждого КлючЗначение Из Отпечатки Цикл
		МассивОтпечатковСертификатов.Добавить(КлючЗначение.Ключ);
	КонецЦикла;
	
	ОтпечаткиСервера = ЭлектронныеДокументыСлужебныйВызовСервера.МассивОтпечатковСертификатов();
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивОтпечатковСертификатов, ОтпечаткиСервера, Истина);
	
	ЗаполнитьСписокСертификатовИДокументов(МассивОтпечатковСертификатов);
	ЗаполнитьСписокДокументовПоСертификату();
	
КонецПроцедуры

&НаКлиенте
Функция ЕстьДокументыНаПодпись() 
	
	ПроверочныеДанные = ?(Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено,
		ТаблицаСертификатов[0], Элементы.ТаблицаСертификатов.ТекущиеДанные);
	
	Если ПроверочныеДанные.КоличествоДокументов = 0 Тогда
		ТекстПредупреждения = ВернутьСтр("ru = 'По данному сертификату нет документов на подпись'");
		ПоказатьПредупреждение(, ТекстПредупреждения);
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Процедура ПерейтиНаСтраницу(КДетализации)
	
	Если КДетализации Тогда
		Элементы.СтраницыАРМ.ТекущаяСтраница = Элементы.СтраницыАРМ.ПодчиненныеЭлементы.СтраницаДетализации;
		Заголовок = ВернутьСтр("ru = 'Документы на подпись по сертификату'")+ ": " + СертификатПодписи;
	Иначе
		Элементы.СтраницыАРМ.ТекущаяСтраница = Элементы.СтраницыАРМ.ПодчиненныеЭлементы.СтраницаСводки;
		Заголовок = ВернутьСтр("ru = 'Документы на подпись'");
	КонецЕсли;
	
	Если ЭтоСертификатСбербанка(СертификатПодписи) Тогда
		Элементы.Подписать.Заголовок = ВернутьСтр("ru = 'Подписать отмеченные'");
	Иначе
		Элементы.Подписать.Заголовок = ВернутьСтр("ru = 'Подписать и отправить отмеченные'");
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписокДокументовПоСертификату()
	
	ТаблицаДокументов.Очистить();
	ПараметрыОтбора = Новый Структура("Сертификат", СертификатПодписи);
	СтрокиДокументов = СводнаяТаблица.НайтиСтроки(ПараметрыОтбора);
	
	Для Каждого СтрокаСДокументом Из СтрокиДокументов Цикл
		СтрокаТаблицы = ТаблицаДокументов.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТаблицы, СтрокаСДокументом);
	КонецЦикла;
		
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЭтоСертификатСбербанка(Сертификат)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
		|	ПрограммыБанков.СертификатЭП
		|ИЗ
		|	РегистрСведений.ПрограммыБанков КАК ПрограммыБанков
		|ГДЕ
		|	ПрограммыБанков.СертификатЭП = &СертификатЭП
		|	И ПрограммыБанков.ПрограммаБанка = &ПрограммаБанка";
	
	Запрос.УстановитьПараметр("ПрограммаБанка", Перечисления.ПрограммыБанка.СбербанкОнлайн);
	Запрос.УстановитьПараметр("СертификатЭП", Сертификат);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат НЕ (РезультатЗапроса.Пустой());
	
КонецФункции

&НаКлиенте
Процедура ОповеститьПользователя(КолПодписанных, КолПодготовленных, КолОтправленных)
	
	ТекстСостояния = ВернутьСтр("ru = 'Подписано произвольных ЭД: (%1)'");
	Количество = 0;
	Если КолОтправленных > 0 Тогда
		ТекстСостояния = ТекстСостояния + Символы.ПС + ВернутьСтр("ru = 'Отправлено: (%2)'");
		Количество = КолОтправленных;
	ИначеЕсли КолПодготовленных > 0 Тогда
		ТекстСостояния = ВернутьСтр("ru = 'Подготовлено к отправке: (%2)'");
		Количество = КолПодготовленных;
	КонецЕсли;
	ТекстЗаголовка = ВернутьСтр("ru = 'Обмен электронными документами'");
	ТекстСостояния = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСостояния, КолПодписанных, Количество);
	ПоказатьОповещениеПользователя(ТекстЗаголовка, , ТекстСостояния);
	
	Оповестить("ОбновитьСостояниеЭД");
	
КонецПроцедуры

&НаКлиенте
Процедура ДействияПриОткрытии()
	
	Отказ = Ложь;
	ИспользуетсяОбменСБанками = ИспользуетсяОбменСБанками();
	
	Оповещение = Новый ОписаниеОповещения("ПослеПолученияОтпечатковВыполнитьДействия", ЭтотОбъект);
	ЭлектроннаяПодписьКлиент.ПолучитьОтпечаткиСертификатов(
		Оповещение, Истина, НЕ ВыполнятьКОНаСервере И НЕ ИспользуетсяОбменСБанками);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Служебные обработчики асинхронных диалогов

&НаКлиенте
Процедура ПослеПолученияОтпечатковВыполнитьДействия(Отпечатки, ДополнительныеПараметры = Неопределено) Экспорт
	
	Если ТипЗнч(Отпечатки) <> Тип("Соответствие") Тогда
		Закрыть();
		Возврат;
	КонецЕсли;
	
	МассивОтпечатковСертификатов = Новый Массив;
	Для Каждого КлючЗначение Из Отпечатки Цикл
		МассивОтпечатковСертификатов.Добавить(КлючЗначение.Ключ);
	КонецЦикла;
	
	ОтпечаткиСервера = ЭлектронныеДокументыСлужебныйВызовСервера.МассивОтпечатковСертификатов();
	
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивОтпечатковСертификатов, ОтпечаткиСервера);

	ЗаполнитьСписокСертификатовИДокументов(МассивОтпечатковСертификатов);
	
	Если ТаблицаСертификатов.Количество() = 0 Тогда
		ТекстПредупреждения = ВернутьСтр("ru = 'Нет сертификатов подписи для пользователя
										|или не настроены правила подписи документов!'");
		ОписаниеОповещения = Новый ОписаниеОповещения("ПослеЗакрытияПредупреждения", ЭтотОбъект);
		ПоказатьПредупреждение(ОписаниеОповещения, ТекстПредупреждения);
	ИначеЕсли ТаблицаСертификатов.Количество() > 1 Тогда
		ПерейтиНаСтраницу(Ложь);
	Иначе
		СертификатПодписи = ТаблицаСертификатов[0].Сертификат;
		ЗаполнитьСписокДокументовПоСертификату();
		ПерейтиНаСтраницу(Истина);
		Элементы.ГруппаКнопкиНазад.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияПредупреждения(ДополнительныеПараметры = Неопределено) Экспорт
	
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеУстановкиРасширенияДляРаботыСКриптографией(РасширениеУстановлено, ДополнительныеПараметры) Экспорт
	
	Если РасширениеУстановлено = Истина Тогда
		Доступность = Истина;
		ВыполнятьКОНаСервере = Ложь;
		ДействияПриОткрытии();
	Иначе
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Обновить(Команда)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

&НаКлиенте
Процедура Подписать(Команда)
	
	МассивЭД = Новый Массив;
	Для Каждого ТекСтрока Из ТаблицаДокументов Цикл
		Если ТекСтрока.Выбрать Тогда
			МассивЭД.Добавить(ТекСтрока.ЭлектронныйДокумент);
		КонецЕсли;
	КонецЦикла;
	
	ЭлектронныеДокументыКлиент.СформироватьПодписатьОтправитьЭД(Неопределено, МассивЭД);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодписатьВсе(Команда)
	
	Если НЕ ЕстьДокументыНаПодпись() Тогда
		Возврат;
	КонецЕсли;
	
	// По выделенному сертификату найдем все документы на подпись
	СертификатПодписи = ?(Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено,
		ТаблицаСертификатов[0].Сертификат, Элементы.ТаблицаСертификатов.ТекущиеДанные.Сертификат);
	
	ПараметрыОтбора = Новый Структура("Сертификат", СертификатПодписи);
	СтрокиДокументов = СводнаяТаблица.НайтиСтроки(ПараметрыОтбора);
	
	МассивДокументовНаПодпись = Новый Массив;
	Для Каждого ЭлементТаблицы Из СтрокиДокументов Цикл
		МассивДокументовНаПодпись.Добавить(ЭлементТаблицы.ЭлектронныйДокумент);
	КонецЦикла;
	
	ЭлектронныеДокументыКлиент.СформироватьПодписатьОтправитьЭД(МассивДокументовНаПодпись);
	
КонецПроцедуры

&НаКлиенте
Процедура ВернутьсяКСпискуСертификатов(Команда)
	
	ПерейтиНаСтраницу(Ложь);
	
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиКСпискуДокументов(Команда)
	
	СертификатПодписи = ?(Элементы.ТаблицаСертификатов.ТекущиеДанные = Неопределено,
		ТаблицаСертификатов[0].Сертификат, Элементы.ТаблицаСертификатов.ТекущиеДанные.Сертификат);
		
	Если НЕ ЕстьДокументыНаПодпись() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьСписокДокументовПоСертификату();
	ПерейтиНаСтраницу(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтметитьВыделенные(Команда)
	
	МассивСтрок = Элементы.ТаблицаДокументов.ВыделенныеСтроки;
	Для Каждого НомерСтроки Из МассивСтрок Цикл
		СтрокаТаблицы = ТаблицаДокументов.НайтиПоИдентификатору(НомерСтроки);
		Если СтрокаТаблицы <> Неопределено Тогда
			СтрокаТаблицы.Выбрать = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьОтметкуСоВсехСтрок(Команда)
	
	Для Каждого ТекДокумент Из ТаблицаДокументов Цикл
		Если ТекДокумент.Выбрать Тогда
			ТекДокумент.Выбрать = Ложь;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийПолейФормы

&НаКлиенте
Процедура КонтрагентПриИзменении(Элемент)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаДокументовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЭлектронныеДокументыСлужебныйКлиент.ОткрытьЭДДляПросмотра(Элементы.ТаблицаДокументов.ТекущиеДанные.ЭлектронныйДокумент);
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСертификатовВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СертификатПодписи = Элементы.ТаблицаСертификатов.ТекущиеДанные.Сертификат;
	Если НЕ ЕстьДокументыНаПодпись() Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьСписокДокументовПоСертификату();
	ПерейтиНаСтраницу(Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ВидЭДПриИзменении(Элемент)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

&НаКлиенте
Процедура НаправлениеЭДПриИзменении(Элемент)
	
	ПерезаполнитьТаблицы();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ВыполнятьКОНаСервере Тогда
		ДействияПриОткрытии();
	Иначе
		Доступность = Ложь;
		Обработчик = Новый ОписаниеОповещения("ПослеУстановкиРасширенияДляРаботыСКриптографией", ЭтотОбъект);
		ТекстВопроса = ВернутьСтр("ru = 'Для работы с ЭП необходимо установить
								|расширение работы с криптографией.'");
		ЭлектроннаяПодписьКлиент.УстановитьРасширение(Ложь, Обработчик, ТекстВопроса);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьЗначениеФункциональнойОпции("ИспользоватьОбменЭД") Тогда
		ТекстСообщения = ЭлектронныеДокументыСлужебныйВызовСервера.ТекстСообщенияОНеобходимостиНастройкиСистемы("РаботаСЭД");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , , , Отказ);
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ ЭлектронныеДокументыСлужебныйВызовСервера.ПолучитьЗначениеФункциональнойОпции("ИспользоватьЭлектронныеПодписиЭД") Тогда
		ТекстСообщения = ЭлектронныеДокументыСлужебныйВызовСервера.ТекстСообщенияОНеобходимостиНастройкиСистемы("ПодписаниеЭД");
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , , , Отказ);
		Отказ = Истина;
	КонецЕсли;
	
	Если Не Отказ Тогда
		Элементы.СтраницыАРМ.ОтображениеСтраниц = ОтображениеСтраницФормы.Нет;
		
		АктуальныеВидыЭД = ЭлектронныеДокументыПовтИсп.ПолучитьАктуальныеВидыЭД();
		МассивВычитания = Новый Массив;
		МассивВычитания.Добавить(Перечисления.ВидыЭД.ЗапросВыписки);
		МассивВычитания.Добавить(Перечисления.ВидыЭД.ВыпискаБанка);
		ОбщегоНазначенияКлиентСервер.СократитьМассив(АктуальныеВидыЭД, МассивВычитания);
		Элементы.ВидЭД.СписокВыбора.ЗагрузитьЗначения(АктуальныеВидыЭД);
		ВыполнятьКОНаСервере = ЭлектронныеДокументыСлужебныйВызовСервера.ВыполнятьКриптооперацииНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ОбновитьСостояниеЭД" Тогда
		ПерезаполнитьТаблицы();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиАсинхронныхДиалогов

&НаКлиенте
Процедура ПодписатьОтправитьОповещение(Результат, ДополнительныеПараметры) Экспорт
	
	СоответствиеПрофилейИПараметровСертификатов = Результат.СоответствиеПрофилейИПараметровСертификатов;
	
	КолПодписанных = ДополнительныеПараметры.КолПодписанных;
	МассивЭД = ДополнительныеПараметры.МассивЭД;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеОтправкиПЭД", ЭтотОбъект, КолПодписанных);
	ЭлектронныеДокументыСлужебныйКлиент.ПодготовитьИОтправитьПЭД(МассивЭД, Ложь, СоответствиеПрофилейИПараметровСертификатов, ,
		ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеОтправкиПЭД(Результат, ДополнительныеПараметры) Экспорт
	
	КолПодписанных = 0;
	КолПодготовленных = 0;
	КолОтправленных = 0;
	Если ТипЗнч(Результат) = Тип("Структура") Тогда
		Если НЕ(Результат.Свойство("КолПодготовленных", КолПодготовленных)
				И ТипЗнч(КолПодготовленных) = Тип("Число")) Тогда
			//
			КолПодготовленных = 0;
		КонецЕсли;
		Если НЕ(Результат.Свойство("КолОтправленных", КолОтправленных)
				И ТипЗнч(КолОтправленных) = Тип("Число")) Тогда
			//
			КолОтправленных = 0;
		КонецЕсли;
	КонецЕсли;
	Если ТипЗнч(ДополнительныеПараметры) = Тип("Число") Тогда
		КолПодписанных = ДополнительныеПараметры;
	КонецЕсли;
	
	ОповеститьПользователя(КолПодписанных, КолПодготовленных, КолОтправленных);
	
КонецПроцедуры

#КонецОбласти