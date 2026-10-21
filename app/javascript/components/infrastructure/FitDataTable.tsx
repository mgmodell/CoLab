import React, { useCallback, useEffect, useLayoutEffect, useRef, useState } from "react";
import { DataTable, type DataTableProps, type DataTableValueArray } from "primereact/datatable";

const BOTTOM_MARGIN = 16;
const MIN_HEIGHT = 200;

// Props that only make sense for a paginated table; the table scrolls instead.
type PaginationProps =
  | "paginator"
  | "rows"
  | "first"
  | "rowsPerPageOptions"
  | "paginatorTemplate"
  | "paginatorDropdownAppendTo"
  | "paginatorLeft"
  | "paginatorRight"
  | "paginatorPosition"
  | "paginatorClassName"
  | "currentPageReportTemplate"
  | "alwaysShowPaginator";

type Props = Omit<DataTableProps<DataTableValueArray>, PaginationProps | "scrollable" | "scrollHeight"> & {
  [key: string]: any;
};

/**
 * A DataTable that fills the vertical space remaining in the window (below
 * its own top edge) and scrolls internally instead of paginating. The
 * wrapper is given the remaining window height and the table fills it
 * (scrollHeight="flex"), so its toolbar, headings, filters and footer are
 * always inside that height. Virtual scrolling is not supported in flex mode,
 * so virtualScrollerOptions is ignored; the table scrolls natively.
 */
export default function FitDataTable(props: Props) {
  const {
    paginator,
    rows,
    first,
    rowsPerPageOptions,
    paginatorTemplate,
    paginatorDropdownAppendTo,
    paginatorLeft,
    paginatorRight,
    paginatorPosition,
    paginatorClassName,
    currentPageReportTemplate,
    alwaysShowPaginator,
    scrollable,
    scrollHeight,
    virtualScrollerOptions,
    ...tableProps
  } = props as any;

  const wrapperRef = useRef<HTMLDivElement>(null);
  const [height, setHeight] = useState<number>(MIN_HEIGHT * 2);

  const recalc = useCallback(() => {
    const el = wrapperRef.current;
    if (!el) return;
    const top = el.getBoundingClientRect().top;
    // Space below the table that belongs to its containers (bottom padding,
    // border and margin of each ancestor, e.g. a panel's frame).
    let below = 0;
    for (
      let node = el.parentElement;
      node && node !== document.body && node !== document.documentElement;
      node = node.parentElement
    ) {
      const style = window.getComputedStyle(node);
      below +=
        (parseFloat(style.paddingBottom) || 0) +
        (parseFloat(style.borderBottomWidth) || 0) +
        (parseFloat(style.marginBottom) || 0);
    }
    setHeight(
      Math.max(MIN_HEIGHT, Math.floor(window.innerHeight - top - BOTTOM_MARGIN - below))
    );
  }, []);

  useLayoutEffect(recalc);

  useEffect(() => {
    window.addEventListener("resize", recalc);
    let observer: ResizeObserver | undefined;
    if (typeof ResizeObserver !== "undefined") {
      observer = new ResizeObserver(recalc);
      observer.observe(document.body);
    }
    return () => {
      window.removeEventListener("resize", recalc);
      observer?.disconnect();
    };
  }, [recalc]);

  return (
    <div
      ref={wrapperRef}
      className="fit-data-table"
      style={{ height: `${height}px`, overflow: "hidden" }}
    >
      <DataTable {...tableProps} scrollable scrollHeight="flex" />
    </div>
  );
}
