
&НаКлиенте
Процедура ДокументПриИзменении(Элемент)
	ОбновитьТЧНаСервере();
КонецПроцедуры

&НаСервере
Процедура ОбновитьТЧНаСервере()
	Объект.СтрокиРТиУ.Очистить();
	Объект.СтрокиПередачаОС.Очистить();
		
	Если ТипЗнч(Объект.Документ) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
		Элементы.ТабличныеЧасти.ТекущаяСтраница = Элементы.ГруппаСтрокиРТиУ	
	ИначеЕсли  ТипЗнч(Объект.Документ) = Тип("ДокументСсылка.ПередачаОС") Тогда
		Элементы.ТабличныеЧасти.ТекущаяСтраница = Элементы.ГруппаСтрокиПеремещениеОС;
	
	КонецЕсли;
	
	Обработка = РеквизитФормыВЗначение("Объект");
	Обработка.ЗаполнитьТабличныеЧасти();
	ЗначениеВРеквизитФормы(Обработка,"Объект");
	
КонецПроцедуры

&НаКлиенте
Процедура Распределить(Команда)
	Отказ = Ложь;
	ПроверитьЗаполнениеРаспределения(Отказ);
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	//СуммаКоэффициентов = Объект.РаспределениеAU.Итог("Коэффициент");
	
	РаспределитьНаСервере();
	
	
	
	/////////////////////////
 //   Если ТипЗнч(Объект.Документ) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
 //   	ВыбранныеИдентификаторы = Элементы.СтрокиРТиУ.ВыделенныеСтроки;
 //   	МассивСтрок = Новый Массив;
 //   	Для Каждого Идентификатор Из  ВыбранныеИдентификаторы Цикл
 //   		ВыбраннаяСтрока = Объект.СтрокиРТиУ.НайтиПоИдентификатору(Идентификатор);
 //   		МассивСтрок.Добавить(ВыбраннаяСтрока);
 //   	КонецЦикла;
 //   	
 //   	Для Каждого ВыбраннаяСтрока Из МассивСтрок Цикл
 //   		
 //   		ПроверяемыеРеквизиты = Новый Структура;
 //   		ПроверяемыеРеквизиты.Вставить("Количество",ВыбраннаяСтрока.Количество);
 //   		ПроверяемыеРеквизиты.Вставить("Сумма",ВыбраннаяСтрока.Сумма);
 //   		ПроверяемыеРеквизиты.Вставить("СуммаНДС",ВыбраннаяСтрока.СуммаНДС);
 //   		ПроверяемыеРеквизиты.Вставить("СуммаБезНДСРуб", ВыбраннаяСтрока.СуммаБезНДСРуб);
 //   		ПроверяемыеРеквизиты.Вставить("СуммаНДСРуб",ВыбраннаяСтрока.СуммаНДСРуб);
 //   		

 //   		Если  Объект.РаспределениеAU.Количество()>1 Тогда
 //   			Для Итератор = 1 по Объект.РаспределениеAU.Количество()-1 Цикл
 //   				НСтр = Объект.СтрокиРТиУ.Добавить();
 //   				ЗаполнитьЗначенияСвойств(Нстр,ВыбраннаяСтрока);
 //   				Нстр.КостЦентр = Объект.РаспределениеAU[Итератор].AU;
 //   				Нстр.Количество = ВыбраннаяСтрока.Количество *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.Количество = ПроверяемыеРеквизиты.Количество - Нстр.Количество;
 //   				Нстр.Сумма = ВыбраннаяСтрока.Сумма *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.Сумма = ПроверяемыеРеквизиты.Сумма - Нстр.Сумма;
 //   				НСтр.СуммаНДС =  ВыбраннаяСтрока.СуммаНДС *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СуммаНДС = ПроверяемыеРеквизиты.СуммаНДС - Нстр.СуммаНДС;
 //   				Нстр.СуммаБезНДСРуб =   ВыбраннаяСтрока.СуммаБезНДСРуб *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СуммаБезНДСРуб = ПроверяемыеРеквизиты.СуммаБезНДСРуб - Нстр.СуммаБезНДСРуб;
 //   				Нстр.СуммаНДСРуб = ВыбраннаяСтрока.СуммаНДСРуб *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СуммаНДСРуб = ПроверяемыеРеквизиты.СуммаНДСРуб - Нстр.СуммаНДСРуб;
 //   			КонецЦикла;
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.КостЦентр = Объект.РаспределениеAU[0].AU;
 //   		ВыбраннаяСтрока.Количество = ВыбраннаяСтрока.Количество *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.Количество = ПроверяемыеРеквизиты.Количество - ВыбраннаяСтрока.Количество;
 //   		Если ПроверяемыеРеквизиты.Количество <> 0 Тогда
 //   			 ВыбраннаяСтрока.Количество = ВыбраннаяСтрока.Количество + ПроверяемыеРеквизиты.Количество; 
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.Сумма = ВыбраннаяСтрока.Сумма *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.Сумма = ПроверяемыеРеквизиты.Сумма - ВыбраннаяСтрока.Сумма;
 //   		Если ПроверяемыеРеквизиты.Сумма <> 0 Тогда
 //   			 ВыбраннаяСтрока.Сумма = ВыбраннаяСтрока.Сумма + ПроверяемыеРеквизиты.Сумма;
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.СуммаНДС =  ВыбраннаяСтрока.СуммаНДС *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.СуммаНДС = ПроверяемыеРеквизиты.СуммаНДС - ВыбраннаяСтрока.СуммаНДС;
 //   		Если ПроверяемыеРеквизиты.СуммаНДС <> 0 Тогда
 //   			 ВыбраннаяСтрока.СуммаНДС = ВыбраннаяСтрока.СуммаНДС + ПроверяемыеРеквизиты.СуммаНДС;
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.СуммаБезНДСРуб =   ВыбраннаяСтрока.СуммаБезНДСРуб *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.СуммаБезНДСРуб = ПроверяемыеРеквизиты.СуммаБезНДСРуб - ВыбраннаяСтрока.СуммаБезНДСРуб;
 //   		Если ПроверяемыеРеквизиты.СуммаБезНДСРуб <> 0 Тогда
 //   			 ВыбраннаяСтрока.СуммаБезНДСРуб = ВыбраннаяСтрока.СуммаБезНДСРуб + ПроверяемыеРеквизиты.СуммаБезНДСРуб;
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.СуммаНДСРуб = ВыбраннаяСтрока.СуммаНДСРуб *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.СуммаНДСРуб = ПроверяемыеРеквизиты.СуммаНДСРуб - ВыбраннаяСтрока.СуммаНДСРуб;
 //   		Если ПроверяемыеРеквизиты.СуммаНДСРуб <> 0 Тогда
 //   			 ВыбраннаяСтрока.СуммаНДСРуб = ВыбраннаяСтрока.СуммаНДСРуб + ПроверяемыеРеквизиты.СуммаНДСРуб ;
 //   		КонецЕсли;
 //   	КонецЦикла;
 //   	
 //   ИначеЕсли ТипЗнч(Объект.Документ) = Тип("ДокументСсылка.ПередачаОС") Тогда
 //   	ВыбранныеИдентификаторы = Элементы.СтрокиПередачаОС.ВыделенныеСтроки;
 //   	МассивСтрок = Новый Массив;
 //   	Для Каждого Идентификатор Из  ВыбранныеИдентификаторы Цикл
 //   		ВыбраннаяСтрока = Объект.СтрокиПередачаОС.НайтиПоИдентификатору(Идентификатор);
 //   		МассивСтрок.Добавить(ВыбраннаяСтрока);
 //   	КонецЦикла;
 //   	
 //   	Для Каждого ВыбраннаяСтрока Из МассивСтрок Цикл
 //   		ПроверяемыеРеквизиты = Новый Структура;
 //   		ПроверяемыеРеквизиты.Вставить("СтоимостьБУ",ВыбраннаяСтрока.СтоимостьБУ);
 //   		ПроверяемыеРеквизиты.Вставить("АмортизацияБУ",ВыбраннаяСтрока.АмортизацияБУ);
 //   		ПроверяемыеРеквизиты.Вставить("АмортизацияЗаМесяцБУ",ВыбраннаяСтрока.АмортизацияЗаМесяцБУ);
 //   		ПроверяемыеРеквизиты.Вставить("СтоимостьНУ", ВыбраннаяСтрока.СтоимостьНУ);
 //   		ПроверяемыеРеквизиты.Вставить("АмортизацияНУ",ВыбраннаяСтрока.АмортизацияНУ);
 //   		ПроверяемыеРеквизиты.Вставить("АмортизацияЗаМесяцНУ",ВыбраннаяСтрока.АмортизацияЗаМесяцНУ);
 //   		ПроверяемыеРеквизиты.Вставить("Сумма",ВыбраннаяСтрока.Сумма);
 //   		ПроверяемыеРеквизиты.Вставить("СуммаНДС",ВыбраннаяСтрока.СуммаНДС);
 //   		ПроверяемыеРеквизиты.Вставить("СуммаКапитальныхВложенийВключаемыхВРасходыНУ",ВыбраннаяСтрока.СуммаКапитальныхВложенийВключаемыхВРасходыНУ);
 //   		
 //   		Если  Объект.РаспределениеAU.Количество()>1 Тогда
 //   			Для Итератор = 1 по Объект.РаспределениеAU.Количество()-1 Цикл
 //   				НСтр = Объект.СтрокиПередачаОС.Добавить();
 //   				ЗаполнитьЗначенияСвойств(Нстр,ВыбраннаяСтрока);
 //   				Нстр.КостЦентр = Объект.РаспределениеAU[Итератор].AU;
 //   				
 //   				Нстр.СтоимостьБУ = ВыбраннаяСтрока.СтоимостьБУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СтоимостьБУ = ПроверяемыеРеквизиты.СтоимостьБУ - Нстр.СтоимостьБУ;
 //   				
 //   				Нстр.АмортизацияБУ = ВыбраннаяСтрока.АмортизацияБУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.АмортизацияБУ = ПроверяемыеРеквизиты.АмортизацияБУ - Нстр.АмортизацияБУ;
 //   				
 //   				НСтр.АмортизацияЗаМесяцБУ =  ВыбраннаяСтрока.АмортизацияЗаМесяцБУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.АмортизацияЗаМесяцБУ = ПроверяемыеРеквизиты.АмортизацияЗаМесяцБУ - Нстр.АмортизацияЗаМесяцБУ;
 //   				
 //   				Нстр.СтоимостьНУ =   ВыбраннаяСтрока.СтоимостьНУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СтоимостьНУ = ПроверяемыеРеквизиты.СтоимостьНУ - Нстр.СтоимостьНУ;
 //   				
 //   				Нстр.АмортизацияНУ = ВыбраннаяСтрока.АмортизацияНУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.АмортизацияНУ = ПроверяемыеРеквизиты.АмортизацияНУ - Нстр.АмортизацияНУ;
 //   				
 //   				Нстр.АмортизацияЗаМесяцНУ = ВыбраннаяСтрока.АмортизацияЗаМесяцНУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.АмортизацияЗаМесяцНУ = ПроверяемыеРеквизиты.АмортизацияЗаМесяцНУ - Нстр.АмортизацияЗаМесяцНУ;
 //   				
 //   				Нстр.Сумма = ВыбраннаяСтрока.Сумма *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.Сумма = ПроверяемыеРеквизиты.Сумма - Нстр.Сумма;
 //   				
 //   				НСтр.СуммаНДС =  ВыбраннаяСтрока.СуммаНДС *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СуммаНДС = ПроверяемыеРеквизиты.СуммаНДС - Нстр.СуммаНДС;
 //   				
 //   				Нстр.СуммаКапитальныхВложенийВключаемыхВРасходыНУ = ВыбраннаяСтрока.СуммаКапитальныхВложенийВключаемыхВРасходыНУ *  Объект.РаспределениеAU[Итератор].Коэффициент/СуммаКоэффициентов;
 //   				ПроверяемыеРеквизиты.СуммаКапитальныхВложенийВключаемыхВРасходыНУ = ПроверяемыеРеквизиты.СуммаКапитальныхВложенийВключаемыхВРасходыНУ - Нстр.СуммаКапитальныхВложенийВключаемыхВРасходыНУ;
 //   
 //   			КонецЦикла;
 //   		КонецЕсли;
 //   		
 //   		ВыбраннаяСтрока.КостЦентр = Объект.РаспределениеAU[0].AU;
 //   		ВыбраннаяСтрока.СтоимостьБУ = ВыбраннаяСтрока.СтоимостьБУ *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.СтоимостьБУ = ПроверяемыеРеквизиты.СтоимостьБУ - ВыбраннаяСтрока.СтоимостьБУ;
 //   		Если ПроверяемыеРеквизиты.СтоимостьБУ <> 0 Тогда
 //   			 ВыбраннаяСтрока.СтоимостьБУ = ВыбраннаяСтрока.СтоимостьБУ + ПроверяемыеРеквизиты.СтоимостьБУ; 
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.АмортизацияБУ = ВыбраннаяСтрока.АмортизацияБУ *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.АмортизацияБУ = ПроверяемыеРеквизиты.АмортизацияБУ - ВыбраннаяСтрока.АмортизацияБУ;
 //   		Если ПроверяемыеРеквизиты.АмортизацияБУ <> 0 Тогда
 //   			 ВыбраннаяСтрока.АмортизацияБУ = ВыбраннаяСтрока.АмортизацияБУ + ПроверяемыеРеквизиты.АмортизацияБУ;
 //   		КонецЕсли;
 //   		
 //   		ПроверяемыеРеквизиты.Сумма = ПроверяемыеРеквизиты.Сумма - ВыбраннаяСтрока.Сумма;
 //   		Если ПроверяемыеРеквизиты.Сумма <> 0 Тогда
 //   			 ВыбраннаяСтрока.Сумма = ВыбраннаяСтрока.Сумма + ПроверяемыеРеквизиты.Сумма;
 //   		КонецЕсли;
 //   		 
 //   		ВыбраннаяСтрока.СуммаНДС =  ВыбраннаяСтрока.СуммаНДС *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.СуммаНДС = ПроверяемыеРеквизиты.СуммаНДС - ВыбраннаяСтрока.СуммаНДС;
 //   		Если ПроверяемыеРеквизиты.СуммаНДС <> 0 Тогда
 //   			 ВыбраннаяСтрока.СуммаНДС = ВыбраннаяСтрока.СуммаНДС + ПроверяемыеРеквизиты.СуммаНДС;
 //   		КонецЕсли;
 //   		  
 //   		ВыбраннаяСтрока.АмортизацияЗаМесяцБУ =   ВыбраннаяСтрока.АмортизацияЗаМесяцБУ *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.АмортизацияЗаМесяцБУ = ПроверяемыеРеквизиты.АмортизацияЗаМесяцБУ - ВыбраннаяСтрока.АмортизацияЗаМесяцБУ;
 //   		Если ПроверяемыеРеквизиты.АмортизацияЗаМесяцБУ <> 0 Тогда
 //   			 ВыбраннаяСтрока.АмортизацияЗаМесяцБУ = ВыбраннаяСтрока.АмортизацияЗаМесяцБУ + ПроверяемыеРеквизиты.АмортизацияЗаМесяцБУ;
 //   		КонецЕсли;
 //   		ВыбраннаяСтрока.СтоимостьНУ = ВыбраннаяСтрока.СтоимостьНУ *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.СтоимостьНУ = ПроверяемыеРеквизиты.СтоимостьНУ - ВыбраннаяСтрока.СтоимостьНУ;
 //   		Если ПроверяемыеРеквизиты.СтоимостьНУ <> 0 Тогда
 //   			 ВыбраннаяСтрока.СтоимостьНУ = ВыбраннаяСтрока.СтоимостьНУ + ПроверяемыеРеквизиты.СтоимостьНУ ;
 //   		КонецЕсли;
 //   		
 //   		ВыбраннаяСтрока.АмортизацияНУ =  ВыбраннаяСтрока.АмортизацияНУ *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.АмортизацияНУ = ПроверяемыеРеквизиты.АмортизацияНУ - ВыбраннаяСтрока.СуммаНДС;
 //   		Если ПроверяемыеРеквизиты.АмортизацияНУ <> 0 Тогда
 //   			 ВыбраннаяСтрока.АмортизацияНУ = ВыбраннаяСтрока.АмортизацияНУ + ПроверяемыеРеквизиты.АмортизацияНУ;
 //   		КонецЕсли;
 //   		 
 //   		ВыбраннаяСтрока.АмортизацияЗаМесяцНУ =  ВыбраннаяСтрока.АмортизацияЗаМесяцНУ *  Объект.РаспределениеAU[0].Коэффициент/СуммаКоэффициентов;
 //   		ПроверяемыеРеквизиты.АмортизацияЗаМесяцНУ = ПроверяемыеРеквизиты.АмортизацияЗаМесяцНУ - ВыбраннаяСтрока.СуммаНДС;
 //   		Если ПроверяемыеРеквизиты.АмортизацияЗаМесяцНУ <> 0 Тогда
 //   			 ВыбраннаяСтрока.АмортизацияЗаМесяцНУ = ВыбраннаяСтрока.АмортизацияЗаМесяцНУ + ПроверяемыеРеквизиты.АмортизацияЗаМесяцНУ;
 ////   		КонецЕсли;
 ////

 //   		 
 //   	КонецЦикла;

		
	//КонецЕсли;
КонецПроцедуры

Процедура РаспределитьНаСервере()
	Обработка = РеквизитФормыВЗначение("Объект");
	СтруктураВыбранныхСтрок = ПолучитьСтруктуруВыбранныхСтрок();
	Обработка.Распределить(СтруктураВыбранныхСтрок);
	ЗначениеВРеквизитФормы(Обработка,"Объект");	
КонецПроцедуры



&НаСервере
Процедура ПроверитьЗаполнениеРаспределения(Отказ)
	Сообщение = Новый СообщениеПользователю();
	Сообщение.ИдентификаторНазначения = ЭтаФорма.УникальныйИдентификатор;
	Если Объект.РаспределениеAU.Количество()=0 Тогда
		Сообщение.Текст = "Не заполнена таблица распределения";
		Сообщение.Сообщить();
		Отказ = Истина;
	КонецЕсли;
	НеЗаполненоКоличество = (Объект.РаспределениеAU.НайтиСтроки(Новый Структура("Коэффициент",0)).Количество() >0);
	НеЗаполненКостЦентр = (Объект.РаспределениеAU.НайтиСтроки(Новый Структура("AU",Справочники.КостЦентры.ПустаяСсылка())).Количество() >0);
	Если НеЗаполненоКоличество Тогда
		Сообщение.Текст = "Не заполнено количество";
		Сообщение.Сообщить();
		Отказ = Истина;
	КонецЕсли;
	Если НеЗаполненКостЦентр Тогда
		Сообщение.Текст = "Не заполнен AU";
		Сообщение.Сообщить();
		Отказ = Истина;
	КонецЕсли;

КонецПроцедуры


&НаСервере
Процедура ПерезаполнитьНаСервере()
	ДокументОбъект =  Объект.Документ.ПолучитьОбъект();
	
	Если ТипЗнч(Объект.Документ) = Тип("ДокументСсылка.РеализацияТоваровУслуг") Тогда
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтрокиРТиУ.ВидНоменклатуры,
		|	СтрокиРТиУ.Содержание,
		|	СтрокиРТиУ.Количество,
		|	СтрокиРТиУ.Цена,
		|	СтрокиРТиУ.Сумма,
		|	СтрокиРТиУ.СтавкаНДС,
		|	СтрокиРТиУ.КоличествоМест,
		|	СтрокиРТиУ.СуммаНДС,
		|	СтрокиРТиУ.Номенклатура,
		|	СтрокиРТиУ.Ticket,
		|	СтрокиРТиУ.Well,
		|	СтрокиРТиУ.Oilfield,
		|	СтрокиРТиУ.ProductLine,
		|	СтрокиРТиУ.КостЦентр,
		|	СтрокиРТиУ.TicketNumber,
		|	СтрокиРТиУ.ЕдиницаИзмерения,
		|	СтрокиРТиУ.СодержаниеEng,
		|	СтрокиРТиУ.Коэффициент,
		|	СтрокиРТиУ.WO,
		|	СтрокиРТиУ.СуммаБезНДСРуб,
		|	СтрокиРТиУ.СуммаНДСРуб,
		|	СтрокиРТиУ.НомерГДТ,
		|	СтрокиРТиУ.СтранаПроисхождения
		|ПОМЕСТИТЬ ВТ_СтрокиРТиУ
		|ИЗ
		|	&СтрокиРТиУ КАК СтрокиРТиУ
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_СтрокиРТиУ.ВидНоменклатуры,
		|	ВТ_СтрокиРТиУ.Содержание,
		|	ВТ_СтрокиРТиУ.Количество,
		|	ВТ_СтрокиРТиУ.Цена,
		|	ВТ_СтрокиРТиУ.Сумма,
		|	ВТ_СтрокиРТиУ.СтавкаНДС,
		|	ВТ_СтрокиРТиУ.КоличествоМест,
		|	ВТ_СтрокиРТиУ.СуммаНДС,
		|	ВТ_СтрокиРТиУ.Номенклатура,
		|	ВТ_СтрокиРТиУ.Ticket,
		|	ВТ_СтрокиРТиУ.Well,
		|	ВТ_СтрокиРТиУ.Oilfield,
		|	ВТ_СтрокиРТиУ.ProductLine,
		|	ВТ_СтрокиРТиУ.КостЦентр,
		|	ВТ_СтрокиРТиУ.TicketNumber,
		|	ВТ_СтрокиРТиУ.ЕдиницаИзмерения,
		|	ВТ_СтрокиРТиУ.СодержаниеEng,
		|	ВТ_СтрокиРТиУ.Коэффициент,
		|	ВТ_СтрокиРТиУ.WO,
		|	ВТ_СтрокиРТиУ.СуммаБезНДСРуб,
		|	ВТ_СтрокиРТиУ.НомерГДТ,
		|	ВТ_СтрокиРТиУ.СтранаПроисхождения
		|ИЗ
		|	ВТ_СтрокиРТиУ КАК ВТ_СтрокиРТиУ
		|ГДЕ
		|	ВТ_СтрокиРТиУ.ВидНоменклатуры = ""Товары""
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_СтрокиРТиУ.ВидНоменклатуры,
		|	ВТ_СтрокиРТиУ.Содержание,
		|	ВТ_СтрокиРТиУ.Количество,
		|	ВТ_СтрокиРТиУ.Цена,
		|	ВТ_СтрокиРТиУ.Сумма,
		|	ВТ_СтрокиРТиУ.СтавкаНДС,
		|	ВТ_СтрокиРТиУ.КоличествоМест,
		|	ВТ_СтрокиРТиУ.СуммаНДС,
		|	ВТ_СтрокиРТиУ.Номенклатура,
		|	ВТ_СтрокиРТиУ.Ticket,
		|	ВТ_СтрокиРТиУ.Well,
		|	ВТ_СтрокиРТиУ.Oilfield,
		|	ВТ_СтрокиРТиУ.ProductLine,
		|	ВТ_СтрокиРТиУ.КостЦентр,
		|	ВТ_СтрокиРТиУ.TicketNumber,
		|	ВТ_СтрокиРТиУ.ЕдиницаИзмерения,
		|	ВТ_СтрокиРТиУ.СодержаниеEng,
		|	ВТ_СтрокиРТиУ.Коэффициент,
		|	ВТ_СтрокиРТиУ.WO,
		|	ВТ_СтрокиРТиУ.СуммаБезНДСРуб,
		|	ВТ_СтрокиРТиУ.СуммаНДСРуб,
		|	ВТ_СтрокиРТиУ.НомерГДТ,
		|	ВТ_СтрокиРТиУ.СтранаПроисхождения
		|ИЗ
		|	ВТ_СтрокиРТиУ КАК ВТ_СтрокиРТиУ
		|ГДЕ
		|	ВТ_СтрокиРТиУ.ВидНоменклатуры = ""Услуги""";
		
		Запрос.УстановитьПараметр("СтрокиРТиУ",Объект.СтрокиРТиУ.Выгрузить());
		РезультатыЗапроса = Запрос.ВыполнитьПакет();
		Если Не  РезультатыЗапроса[1].Пустой() Тогда	
			ТЗТовары  = РезультатыЗапроса[1].Выгрузить();
			ДокументОбъект.Товары.Загрузить(ТЗТовары);
		КонецЕсли;
		Если Не  РезультатыЗапроса[2].Пустой() Тогда
			
			ТЗУслуги = РезультатыЗапроса[2].Выгрузить();
			ДокументОбъект.Услуги.Загрузить(ТЗУслуги);
		КонецЕсли;
		
	ИначеЕсли ТипЗнч(Объект.Документ) = Тип("ДокументСсылка.ПередачаОС") Тогда
		ТЗОС = Объект.СтрокиПередачаОС.Выгрузить();
		ДокументОбъект.ОС.Загрузить(ТЗОС);
		
	КонецЕсли;
	
	Если ДокументОбъект.Проведен Тогда
		РежимЗаписи = РежимЗаписиДокумента.Проведение;
	Иначе 
		РежимЗаписи = РежимЗаписиДокумента.Запись;
		
	КонецЕсли;
	ДокументОбъект.Записать(РежимЗаписи);
	

КонецПроцедуры


&НаКлиенте
Процедура Перезаполнить(Команда)
	ПерезаполнитьНаСервере();
КонецПроцедуры


&НаКлиенте
Процедура Заменить(Команда)
	ОткрытьФорму("Справочник.КостЦентры.ФормаВыбора",,ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	Если ТипЗнч(ВыбранноеЗначение) = Тип("СправочникСсылка.КостЦентры") Тогда
		ЗаменитьНаСервере(ВыбранноеЗначение);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаменитьНаСервере(КостЦентрСсылка)
	Обработка = РеквизитФормыВЗначение("Объект");
	СтруктураВыбранныхСтрок = ПолучитьСтруктуруВыбранныхСтрок();
	Обработка.ЗаменаAU(КостЦентрСсылка, СтруктураВыбранныхСтрок);
	ЗначениеВРеквизитФормы(Обработка,"Объект");
КонецПроцедуры

Функция  ПолучитьСтруктуруВыбранныхСтрок()
	ВыбранныеИдентификаторы = Элементы.СтрокиРТиУ.ВыделенныеСтроки;
	НомераСтрокТовары = Новый Массив;
	НомераСтрокУслуги = Новый Массив;
	Для Каждого Идентификатор Из  ВыбранныеИдентификаторы Цикл
		ВыбраннаяСтрока = Объект.СтрокиРТиУ.НайтиПоИдентификатору(Идентификатор);
		Если  ВыбраннаяСтрока.ВидНоменклатуры = "Товары" Тогда
			НомераСтрокТовары.Добавить(ВыбраннаяСтрока.НомерСтрокиТЧ);
		ИначеЕсли ВыбраннаяСтрока.ВидНоменклатуры = "Услуги" Тогда
			НомераСтрокУслуги.Добавить(ВыбраннаяСтрока.НомерСтрокиТЧ);
		КонецЕсли;
	КонецЦикла;
	ВыбранныеИдентификаторы = Элементы.СтрокиПередачаОС.ВыделенныеСтроки;
	НомераСтрокОС = Новый Массив;
	Для Каждого Идентификатор Из  ВыбранныеИдентификаторы Цикл
		ВыбраннаяСтрока = Объект.СтрокиПередачаОС.НайтиПоИдентификатору(Идентификатор);
		НомераСтрокОС.Добавить(ВыбраннаяСтрока.НомерСтрокиТЧ);
	КонецЦикла;
	
	СтруктураВыбранныхСтрок = Новый Структура();
	СтруктураВыбранныхСтрок.Вставить("НомераСтрокТовары", НомераСтрокТовары);
	СтруктураВыбранныхСтрок.Вставить("НомераСтрокУслуги", НомераСтрокУслуги);
	СтруктураВыбранныхСтрок.Вставить("НомераСтрокОС", НомераСтрокОС);
	
	Возврат  СтруктураВыбранныхСтрок;
	
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ЗначениеЗаполнено(Объект.Документ) Тогда
		 ОбновитьТЧНаСервере();
	КонецЕсли;	
КонецПроцедуры





