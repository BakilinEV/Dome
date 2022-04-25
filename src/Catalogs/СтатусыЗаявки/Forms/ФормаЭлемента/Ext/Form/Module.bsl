﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Оформление = Объект.Ссылка.Оформление.Получить();
	
	Если ТипЗнч(Оформление) <> Тип("Структура") Тогда
		Оформление = Новый Структура;
		Оформление.Вставить("Шрифт"     , Новый Шрифт);
		Оформление.Вставить("ЦветФона"  , Новый Цвет);
		Оформление.Вставить("ЦветТекста", Новый Цвет);
	КонецЕсли;
	
	Шрифт      = Оформление.Шрифт;
	ЦветФона   = Оформление.ЦветФона;
	ЦветТекста = Оформление.ЦветТекста;
	
	Если Параметры.Ключ.Пустая() Тогда
		
		Запрос = Новый Запрос(
		"ВЫБРАТЬ
		|	МАКСИМУМ(СтатусыЗаявки.Код) КАК Код
		|ИЗ
		|	Справочник.СтатусыЗаявки КАК СтатусыЗаявки
		|ГДЕ
		|	СтатусыЗаявки.Код < ""900""");
		
		Выборка = Запрос.Выполнить().Выбрать(); Выборка.Следующий();
		
		Объект.Код = Прав("00"+(Число(Выборка.Код)+1), 3);
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбщийСписокРеквизитов.Очистить();
	
	Форма = ПолучитьФорму("Документ.Заявка.ФормаОбъекта");
	Для Каждого ЭлементТовары Из Форма.ПодчиненныеЭлементы.Товары.ПодчиненныеЭлементы Цикл
		
		МассивЭлементов = Новый Массив;
		
		Если ТипЗнч(ЭлементТовары) = Тип("ГруппаФормы") Тогда
			Для Каждого Элемент Из ЭлементТовары.ПодчиненныеЭлементы Цикл
				МассивЭлементов.Добавить(Элемент);
			КонецЦикла;
		ИначеЕсли ТипЗнч(ЭлементТовары) = Тип("ПолеФормы") Тогда
			МассивЭлементов.Добавить(ЭлементТовары);
		КонецЕсли;
		
		Для Каждого Элемент Из МассивЭлементов Цикл
			ПараметрыРеквизита = Новый Структура("Имя, Видимость, Доступность", Элемент.Имя, Элемент.Видимость, Элемент.Доступность);
			ОбщийСписокРеквизитов.Добавить(ПараметрыРеквизита, Прав(Элемент.Имя, 6));
		КонецЦикла;
		
	КонецЦикла;
	
	УстановитьОформление();
	
КонецПроцедуры

&НаСервере
Процедура КомандаИнвертироватьФлагиНаСервере()
	
	Для Каждого Реквизит Из Объект.Реквизиты Цикл
		Реквизит.Видимость = Не Реквизит.Видимость;
		Реквизит.Доступность = Не Реквизит.Доступность;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаИнвертироватьФлаги(Команда)
	
	КомандаИнвертироватьФлагиНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Оформление = Новый Структура;
	Оформление.Вставить("Шрифт"     , Шрифт     );
	Оформление.Вставить("ЦветФона"  , ЦветФона  );
	Оформление.Вставить("ЦветТекста", ЦветТекста);
	
	ТекущийОбъект.Оформление = Новый ХранилищеЗначения(Оформление);
	
КонецПроцедуры

&НаКлиенте
Процедура ОформлениеОчистка(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ЭтаФорма[Элемент.Имя] = ?(Лев(Элемент.Имя, 4) = "Цвет", Новый Цвет, Новый Шрифт);
	
КонецПроцедуры

&НаСервере
Функция СписокОставшихсяРеквизитов(Структурой=Ложь)
	
	ПараметрыНаФорме = Объект.Реквизиты.Выгрузить(, "Имя").ВыгрузитьКолонку("Имя");
	
	Список = Новый СписокЗначений;
	
	Для Каждого ЭлементСписка Из ОбщийСписокРеквизитов Цикл
		Значение = ЭлементСписка.Значение;
		Если ПараметрыНаФорме.Найти(Значение.Имя) = Неопределено Тогда
			Список.Добавить(?(Структурой, Значение, Значение.Имя), ЭлементСписка.Представление);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Список;
	
КонецФункции

&НаКлиенте
Процедура КомандаЗаполнитьВсеРеквизиты(Команда)
	
	Для Каждого Элемент Из СписокОставшихсяРеквизитов(Истина) Цикл
		ЗаполнитьЗначенияСвойств(Объект.Реквизиты.Добавить(), Элемент.Значение);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыИмяНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Элементы.РеквизитыИмя.СписокВыбора.Очистить();
	Для Каждого Элемент Из СписокОставшихсяРеквизитов() Цикл
		Элементы.РеквизитыИмя.СписокВыбора.Добавить(Элемент.Значение, Элемент.Представление);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыИмяАвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
	
	Элементы.РеквизитыИмя.СписокВыбора.Очистить();
	Для Каждого Элемент Из СписокОставшихсяРеквизитов() Цикл
		Элементы.РеквизитыИмя.СписокВыбора.Добавить(Элемент.Значение, Элемент.Представление);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура РеквизитыИмяОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Для Каждого ЭлементСписка Из ОбщийСписокРеквизитов Цикл
		Если ЭлементСписка.Значение.Имя = ВыбранноеЗначение Тогда
			ЗаполнитьЗначенияСвойств(Элементы.Реквизиты.ТекущиеДанные, ЭлементСписка.Значение);
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОформление()
	
	Элементы.Наименование.Шрифт      = Шрифт;
	Элементы.Наименование.ЦветФона   = ЦветФона;
	Элементы.Наименование.ЦветТекста = ЦветТекста;
	
КонецПроцедуры

&НаКлиенте
Процедура ОформлениеПриИзменении(Элемент)
	
	УстановитьОформление();
	
КонецПроцедуры
