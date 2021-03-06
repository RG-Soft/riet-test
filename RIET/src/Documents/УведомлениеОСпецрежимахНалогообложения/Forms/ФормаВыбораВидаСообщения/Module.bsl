
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СозданиеСообщения = Параметры.Свойство("Создание_УведомлениеОСпецрежимахНалогообложения");
	УчитыватьУведомленияНеВходящиеВБРО = Параметры.Свойство("УчитыватьУведомленияНеВходящиеВБРО");
	
	Если Параметры.Свойство("Организация") Тогда
		Организация = Параметры.Организация;
	КонецЕсли;
	
	Если Параметры.Свойство("ВидУведомления") Тогда
		ВидУведомления = Параметры.ВидУведомления;
	КонецЕсли;
	
	Если РегламентированнаяОтчетностьВызовСервера.ИспользуетсяОднаОрганизация() Тогда
		ОргПоУмолчанию = ОбщегоНазначения.ОбщийМодуль("Справочники.Организации").ОрганизацияПоУмолчанию();
		Организация = ОргПоУмолчанию;
	КонецЕсли;
	
	// Формируем список уведомлений
	Если Параметры.Свойство("ВидыПрочихУведомлений")
		И ТипЗнч(Параметры.ВидыПрочихУведомлений) = Тип("Массив") Тогда 
		
		ВидыУведомленийОрг = Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ВидыУведомленийДляОрганизации();
		ВидыУведомленийИП = Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ВидыУведомленийДляИП();
		
		Для Каждого Элемент Из Параметры.ВидыПрочихУведомлений Цикл
			Если ВидыУведомленийИП.Найти(Элемент) <> Неопределено Тогда 
				ВидыСообщенийИП.Добавить(Элемент);
			КонецЕсли;
			Если ВидыУведомленийОрг.Найти(Элемент) <> Неопределено Тогда 
				ВидыСообщенийОрганизации.Добавить(Элемент);
			КонецЕсли;
			ВидыСообщенийОбщий.Добавить(Элемент);
		КонецЦикла;
		СформироватьСписок();
	Иначе 
		СформироватьДерево();
	КонецЕсли;
	
	// Если вид уведомления известен, то позиционируемся на нем
	Если ЗначениеЗаполнено(ВидУведомления) Тогда
		
		ВидУведомления = Параметры.ВидУведомления;
		
		Идентификатор = Неопределено;
		ПолучитьИдентификаторНужногоЭлемента(ВидыСообщений.ПолучитьЭлементы(), ВидУведомления, Идентификатор);
		Элементы.ВидыСообщений.ТекущаяСтрока = Идентификатор;
		
	КонецЕсли;
	
	Если СозданиеСообщения Тогда
		Элементы.Выбрать.Доступность = ЗначениеЗаполнено(Организация);
	Иначе
		// В форме выбора не показываем организацию
		Элементы.Организация.Видимость = Ложь;
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// Если организация и ВидУведомления заполнены, то пропускаем эту форму, сразу создаем объект (только в режиме создания)
	Если СозданиеСообщения Тогда
		Если ЗначениеЗаполнено(Организация) И ЗначениеЗаполнено(ВидУведомления) Тогда
			Данные = Элементы.ВидыСообщений.ТекущиеДанные;
			Если Данные <> Неопределено Тогда
				ОбработкаВыбораВидаУведомления(Данные.Тип, Данные.Наименование);
			КонецЕсли;
			Отказ = Истина;
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВидыСообщенийВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(Организация) И СозданиеСообщения Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			ВернутьСтр("ru='Укажите организацию'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),, "Организация");
		Возврат;
	КонецЕсли;
	
	Данные = Элементы.ВидыСообщений.ТекущиеДанные;
	Если Данные <> Неопределено Тогда
		ОбработкаВыбораВидаУведомления(Данные.Тип, Данные.Наименование);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	
	Элементы.Выбрать.Доступность = ЗначениеЗаполнено(Организация);
	Если ВидыСообщенийИП.Количество() > 0 Тогда
		СформироватьСписок();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормы

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Выбрать(Команда)
	
	Данные = Элементы.ВидыСообщений.ТекущиеДанные;
	Если Данные <> Неопределено Тогда
		ОбработкаВыбораВидаУведомления(Данные.Тип, Данные.Наименование);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура СформироватьСписок()
	
	КорневойУровень = ВидыСообщений.ПолучитьЭлементы();
	КорневойУровень.Очистить();
	
	Если Не ЗначениеЗаполнено(Организация) Тогда 
		Список = ВидыСообщенийОбщий;
	ИначеЕсли РегламентированнаяОтчетностьПереопределяемый.ЭтоЮридическоеЛицо(Организация) Тогда 
		Список = ВидыСообщенийОрганизации;
	Иначе 
		Список = ВидыСообщенийИП;
	КонецЕсли;
	
	Для Каждого ОтправляемыйЭлемент Из Список Цикл
		ДобавитьВеткуВДеревоУведомлений(КорневойУровень, ОтправляемыйЭлемент.Значение);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Функция ДанноеСообщениеДоступноДляИП(Вид)
	
	Если Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеНаПолучениеПатента")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОбУтратеПраваНаПатент")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОПрекращенииДеятельностиПоПатентнойСистеме")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбИзмененииОбъектаНалогообложенияПоУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбОтказеОтУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбУтратеПраваНаУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОПереходеНаУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОПрекращенииДеятельностиПоУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД2")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД4")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_1")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_2") Тогда 
		
		Возврат Истина;
	Иначе 
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Функция ДанноеСообщениеДоступноДляОрганизации(Вид)
	
	Если Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбИзмененииОбъектаНалогообложенияПоУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбОтказеОтУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбУтратеПраваНаУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОПереходеНаУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОПрекращенииДеятельностиПоУСН")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД1")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД3")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.Форма_1_6_Учет")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_1")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_2")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_3_1")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_3_2")
		Или Вид = ПредопределенноеЗначение("Перечисление.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_4") Тогда
		
		Возврат Истина;
	Иначе 
		Возврат Ложь;
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура СформироватьДерево()
	
	ДеревоУведомлений = РеквизитФормыВЗначение("ВидыСообщений");
	
	КорневойУровень = ДеревоУведомлений.Строки;
	
	// Без иерархии
	ДобавитьВеткуВДеревоУведомлений(КорневойУровень, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.Форма_1_6_Учет);
	ДобавитьВеткуВДеревоУведомлений(КорневойУровень, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_1);
	ДобавитьВеткуВДеревоУведомлений(КорневойУровень, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_2);
	ДобавитьВеткуВДеревоУведомлений(КорневойУровень, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_3_1);
	ДобавитьВеткуВДеревоУведомлений(КорневойУровень, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_3_2);
	ДобавитьВеткуВДеревоУведомлений(КорневойУровень, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаС09_4);
	
	// Ветка УСН
	Папка = КорневойУровень.Добавить();
	Папка.Наименование = "УСН";
	Папка.ИндексКартинки = 0;
	ЭлементыПапки = Папка.Строки;
	
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбИзмененииОбъектаНалогообложенияПоУСН);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбОтказеОтУСН);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОбУтратеПраваНаУСН);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОПереходеНаУСН);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.УведомлениеОПрекращенииДеятельностиПоУСН);
	
	// Ветка Патентная система
	Папка = КорневойУровень.Добавить();
	Папка.Наименование = "Патентная система";
	Папка.ИндексКартинки = 0;
	ЭлементыПапки = Папка.Строки;
	
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеНаПолучениеПатента);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОбУтратеПраваНаПатент);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ЗаявлениеОПрекращенииДеятельностиПоПатентнойСистеме);
	
	// Ветка ЕНВД
	Папка = КорневойУровень.Добавить();
	Папка.Наименование = "ЕНВД";
	Папка.ИндексКартинки = 0;
	ЭлементыПапки = Папка.Строки;
	
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД1);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД2);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД3);
	ДобавитьВеткуВДеревоУведомлений(ЭлементыПапки, Перечисления.ВидыУведомленийОСпецрежимахНалогообложения.ФормаЕНВД4);
	
	// Уведомления, не входящие в БРО
	Если УчитыватьУведомленияНеВходящиеВБРО Тогда
		ДобавитьКДеревуПрочиеУведомление(ДеревоУведомлений);
	КонецЕсли;
	
	СоответствиеАдрес = ПоместитьВоВременноеХранилище(ЭтаФорма.УникальныйИдентификатор);
	
	ЗначениеВРеквизитФормы(ДеревоУведомлений, "ВидыСообщений");
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьКДеревуПрочиеУведомление(ДеревоУведомлений)
	
	ТаблицаОписанияОбъектов = РегламентированнаяОтчетность.ТаблицаОписанияОбъектовРегламентированнойОтчетности();
	ТаблицаОписанияУведомлений = ТаблицаОписанияОбъектов.Скопировать(Новый Структура("ВидДокумента, ЯвляетсяАктуальным", Перечисления.СтраницыЖурналаОтчетность.Уведомления, Истина));
	
	// Получаем имена всех групп
	Группы = Новый Массив;
	Для каждого СтрокаТаблицыОписанияУведомлений Из ТаблицаОписанияУведомлений Цикл
		Если Группы.Найти(СтрокаТаблицыОписанияУведомлений.ГруппаВДереве) = Неопределено Тогда
			Группы.Добавить(СтрокаТаблицыОписанияУведомлений.ГруппаВДереве);
		КонецЕсли;
	КонецЦикла;
	
	КорневойУровень = ДеревоУведомлений.Строки;
	
	// Строим дерево
	Для каждого Группа Из Группы Цикл
		
		СтрокиОбъектовДаннойГруппы = ТаблицаОписанияУведомлений.НайтиСтроки(Новый Структура("ГруппаВДереве", Группа));
		Если Группа = "" Тогда
			
			// Если нет группы, добавляем в корень
			Для каждого СтрокаОбъектовДаннойГруппы Из СтрокиОбъектовДаннойГруппы Цикл
			
				Сообщение = КорневойУровень.Добавить();
				Сообщение.Наименование = СтрокаОбъектовДаннойГруппы.Наименование;

				МассивТипов = Новый Массив;
				МассивТипов.Добавить(СтрокаОбъектовДаннойГруппы.ТипОбъекта);
				Сообщение.Тип = Новый ОписаниеТипов(МассивТипов);
				Сообщение.ИндексКартинки = 1;
				
				Сообщение.КонтролирующийОрган = СтрокаОбъектовДаннойГруппы.ВидКонтролирующегоОргана;
			
			КонецЦикла; 
		
		Иначе
			
			// Создаем папку
			Папка = ДеревоУведомлений.Строки.Добавить();
			Папка.Наименование = Группа;
			Папка.ИндексКартинки = 0;
			ЭлементыПапки = Папка.Строки;
			
			// Добавляем в папку элементы
			Для каждого СтрокаОбъектовДаннойГруппы Из СтрокиОбъектовДаннойГруппы Цикл
				Сообщение = ЭлементыПапки.Добавить();
				
				Сообщение.Наименование 	= СтрокаОбъектовДаннойГруппы.Наименование;
				
				МассивТипов = Новый Массив;
				МассивТипов.Добавить(СтрокаОбъектовДаннойГруппы.ТипОбъекта);
				Сообщение.Тип = Новый ОписаниеТипов(МассивТипов);
				Сообщение.ИндексКартинки = 1;
				
				Сообщение.КонтролирующийОрган = СтрокаОбъектовДаннойГруппы.ВидКонтролирующегоОргана;
			КонецЦикла;
			
		КонецЕсли;
	
	КонецЦикла; 
	
КонецПроцедуры

&НаСервере
Функция ЭтоЮридическоеЛицо(Организация)
	
	Возврат РегламентированнаяОтчетностьПереопределяемый.ЭтоЮридическоеЛицо(Организация);
	
КонецФункции

&НаСервере
Функция ЭтотТипНеВходитВБРО(Тип) Экспорт
	
	ТаблицаОбъектовНеВходящихВБРО = РегламентированнаяОтчетность.ТаблицаОписанияОбъектовРегламентированнойОтчетности();
	СведенияПоОбъекту = ТаблицаОбъектовНеВходящихВБРО.Найти(Тип, "ТипОбъекта");
	
	Возврат СведенияПоОбъекту <> Неопределено;
	
КонецФункции

&НаСервере
Функция ПолноеИмяОбъектаМетаданных(Тип)
	
	Возврат Метаданные.НайтиПоТипу(Тип).ПолноеИмя();
	
КонецФункции

&НаСервере
Процедура ДобавитьВеткуВДеревоУведомлений(Родитель, ТипУведомления)
	
	Сообщение = Родитель.Добавить();
	Сообщение.Наименование = Строка(ТипУведомления);
	Сообщение.ИндексКартинки = 1;
	Сообщение.Тип = ТипУведомления;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбораВидаУведомления(Тип, Наименование)
	
	Если ТипЗнч(Тип) = Тип("ПеречислениеСсылка.ВидыУведомленийОСпецрежимахНалогообложения") Тогда
		
		ВидУведомления = Тип;
		
		Если СозданиеСообщения Тогда
			
			ЭтоЮридическоеЛицо = ЭтоЮридическоеЛицо(Организация);
			
			Если ЭтоЮридическоеЛицо Тогда
				
				// Проверка на организаций
				Если НЕ ДанноеСообщениеДоступноДляОрганизации(ВидУведомления) Тогда
					
					ТекстПредупреждения = ВернутьСтр("ru = 'Уведомление ""%1"" можно создавать только для ИП'");
					ТекстПредупреждения = СтрЗаменить(ТекстПредупреждения, "%1", Строка(ВидУведомления));
					Сообщить(ТекстПредупреждения);
					
					Возврат;
				КонецЕсли;
				
			Иначе
				
				// Проверка на ИП
				Если НЕ ДанноеСообщениеДоступноДляИП(ВидУведомления) Тогда
					
					ТекстПредупреждения = ВернутьСтр("ru = 'Уведомление ""%1"" можно создавать только для организаций'");
					ТекстПредупреждения = СтрЗаменить(ТекстПредупреждения, "%1", Строка(ВидУведомления));
					Сообщить(ТекстПредупреждения);
					
					Возврат;
				КонецЕсли;
				
			КонецЕсли;
			
			ОткрытьФорму("Документ.УведомлениеОСпецрежимахНалогообложения.ФормаОбъекта", Новый Структура("Организация,ВидУведомления", Организация, ВидУведомления), ЭтаФорма.ВладелецФормы);
			
		КонецЕсли;
		
		Закрыть(ВидУведомления);
			
	Иначе
		
		// Если это тип, не входящий в БРО, то объект создаем с помощью переопределемого метода
		ТипСоздаваемогоОбъекта = ?(ТипЗнч(Тип) = Тип("ОписаниеТипов") И Тип.Типы().Количество() > 0, Тип.Типы()[0], Тип);
		Если ЭтотТипНеВходитВБРО(ТипСоздаваемогоОбъекта) Тогда
			Если СозданиеСообщения Тогда
				СтандартнаяОбработка = Истина;
				РегламентированнаяОтчетностьКлиентПереопределяемый.СоздатьНовыйОбъект(Организация, ТипСоздаваемогоОбъекта, СтандартнаяОбработка);
				Если СтандартнаяОбработка Тогда
					// Создаем объект
					
					ИмяОбъектаМетаданных = ПолноеИмяОбъектаМетаданных(ТипСоздаваемогоОбъекта);
					ОткрытьФорму(ИмяОбъектаМетаданных + ".ФормаОбъекта", 
						Новый Структура("Организация", Организация), ЭтаФорма.ВладелецФормы);
					
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
		ПараметрыЗакрытия = Новый Структура();
		ПараметрыЗакрытия.Вставить("Тип", 			Тип);
		ПараметрыЗакрытия.Вставить("Наименование", 	Наименование);
		
		Закрыть(ПараметрыЗакрытия);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПолучитьИдентификаторНужногоЭлемента(Элементы, ВидУведомления, Идентификатор)

	Для каждого Элемент из Элементы Цикл
		
		Если Элемент.Тип = ВидУведомления Тогда
			Идентификатор = Элемент.ПолучитьИдентификатор();
			Возврат;
		Конецесли;
		
		ПолучитьИдентификаторНужногоЭлемента(Элемент.ПолучитьЭлементы(), ВидУведомления, Идентификатор);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти
