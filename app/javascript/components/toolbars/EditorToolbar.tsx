import React from "react";

type Props = {};

export default function EditorToolbar(props: Props) {
  return (
    <div id="toolbar">
      <select className="ql-size">
        <option value="small" />
        <option value="large" />
      </select>
      <select className="ql-header">
        <option value="1" />
        <option value="2" />
      </select>
      <select className="ql-font">
        <option value="serif" />
        <option value="monospace" />
      </select>
      <span className="toolbar-separator" />

      <button className="ql-bold" />
      <button className="ql-italic" />
      <button className="ql-underline" />
      <button className="ql-strike" />
      <span className="toolbar-separator" />

      <button className="ql-script" value="sub" />
      <button className="ql-script" value="super" />
      <span className="toolbar-separator" />

      <button className="ql-list" value="ordered" />
      <button className="ql-list" value="bullet" />
      <span className="toolbar-separator" />

      <select className="ql-color" />
      <select className="ql-background" />
      <span className="toolbar-separator" />

      <select className="ql-align">
        <option value="center" />
        <option value="right" />
        <option value="justify" />
      </select>
      <button className="ql-indent" value="-1" />
      <button className="ql-indent" value="+1" />
      <span className="toolbar-separator" />

      <button className="ql-link" />
      <button className="ql-code" />
      <button className="ql-blockquote" />
      <span className="toolbar-separator" />

      <button className="ql-formula" />
      <span className="toolbar-separator" />

      <button className="ql-clean" />
    </div>
  );
}
